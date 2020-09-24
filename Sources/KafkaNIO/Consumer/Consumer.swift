//===----------------------------------------------------------------------===//
//
// This source file is part of the KafkaNIO open source project
//
// Copyright © 2020 Thomas Bartelmess.
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//


import Foundation
import NIO
import NIOSSL
import Logging

public typealias Topic = String
public typealias ConsumerID = String

public typealias MessageHandler = (Record)->Void
typealias PartitionIndex = Int



/// A client that consumes records from a Kafka cluster.
/// This client transparently handles the failure of Kafka brokers, and transparently adapts as topic partitions it fetches migrate within the cluster.
/// This client also interacts with the broker to allow groups of consumers to load balance consumption using consumer groups.
///
/// The consumer maintains TCP connections to the necessary brokers to fetch data.
///
/// ## General
/// The consumer will transparently handle the failure of servers in the Kafka cluster, and adapt as topic-partitions are created or migrate between brokers.
/// It also interacts with the assigned kafka Group Coordinator node to allow multiple consumers to load balance consumption of topics.
///
/// ## Consumer Groups and Subscriptions
/// Kafka maintains an offset for each record in a partition.
public class Consumer {
    enum State {
        case notJoined
        case consuming(groupInfo: GroupInfo, consumers:[NodeConsumer], consumerCoordinator: ConsumerCoordinator)
        case rebalancing(rebalanceFuture: EventLoopFuture<Void>)
        case shuttingDown

        var groupInfo: GroupInfo? {
            switch self {
            case .consuming(groupInfo: let groupInfo, consumers: _, consumerCoordinator: _):
                return groupInfo
            case .notJoined, .shuttingDown, .rebalancing(rebalanceFuture: _):
                return nil
            }
        }
    }

    public let configuration: Configuration


    var partitionInfo: [Int32: OffsetFetchResponse.OffsetFetchResponseTopic.OffsetFetchResponsePartition] = [:]
    var eventLoop: EventLoop
    var clusterClient: ClusterClient
    var autoCommitTask: RepeatedTask?

    private var logger: Logger

    var state: State = .notJoined {
        didSet {
            switch state {
            case .consuming(groupInfo: _, consumers: _, consumerCoordinator: _):
                setupHeartbeatScheduler()
            default:
                removeHeartbeatScheduler()
            }
        }
    }

    /// Connect to the cluster
    static public func connect(configuration: Configuration,
                               eventLoopGroup: EventLoopGroup,
                               logger: Logger = Logger(label: "io.bartelmess.KafkaNIO")) throws -> EventLoopFuture<Consumer> {
        let servers = try configuration.bootstrapServers.map({ socketAddress -> Broker in
            guard let broker = Broker(socketAddress) else {
                throw KafkaError.invalidBootstrapAddress
            }
            return broker
        })
        return ClusterClient.bootstrap(servers: servers,
                                       eventLoopGroup: eventLoopGroup,
                                       tlsConfiguration: configuration.tlsConfiguration,
                                       topics: configuration.subscribedTopics).map { clusterClient in
            Consumer(configuration: configuration,
                     clusterClient: clusterClient,
                     eventLoop: eventLoopGroup.next(),
                     logger: logger)
        }
    }


    init(configuration: Configuration,
         clusterClient: ClusterClient,
         eventLoop: EventLoop,
         logger: Logger) {
        self.configuration = configuration
        self.clusterClient = clusterClient
        self.eventLoop = eventLoop
        self.logger = logger


        self.setupAutocommit()
    }

    func setupAutocommit() {
        logger.info("Configuring AutoCommit")
        switch configuration.autoCommit {
        case .off:
            logger.info("AutoCommit is not enabled")
        case .interval(amount: let amount):
            logger.info("Configuring AutoCommit with \(amount)")
            self.autoCommitTask = eventLoop.scheduleRepeatedAsyncTask(initialDelay: amount, delay: amount) { event -> EventLoopFuture<Void> in
                switch self.state {
                case .consuming(groupInfo: _, consumers: _, consumerCoordinator: let consumerCoordinator):
                    self.logger.info("Commiting offsets")
                    return consumerCoordinator.commitOffsets()
                default:
                    self.logger.info("Not in consuming state, not commiting offsets")
                    return self.eventLoop.makeSucceededFuture(())
                }
            }
        }
    }

    public func updateOffets(recordBatch: RecordBatch) throws {
        guard case .consuming(groupInfo: _, consumers: _, consumerCoordinator: let coordinator) = state else {
            throw KafkaError.invalidState
        }
        let offset = recordBatch.baseOffset + Int64(recordBatch.lastOffsetDelta)
        coordinator.setOffset(offset, partition: recordBatch.partitionIndex, topic: recordBatch.topic)
    }

    public func updateOffsets(recordBatches: [RecordBatch]) throws {
        try recordBatches.forEach(self.updateOffets)
    }

    public func poll(configuration: Consumer.FetchConfiguration = .default) -> EventLoopFuture<[RecordBatch]> {
        switch self.state {

        case .consuming(groupInfo: _, consumers: let consumers, consumerCoordinator: _):
            let futures = consumers.map { $0.poll(fetchConfiguration: configuration) }
            return EventLoopFuture.whenAllComplete(futures, on: eventLoop).flatMapResult { result -> Result<[RecordBatch], KafkaError> in
                let batches = result.compactMap { result -> [RecordBatch]? in
                    if case .success(let batches) = result {
                        return batches
                    }
                    return nil
                }.flatMap { $0 }
                let errors = result.compactMap { (result) -> Error? in
                    if case .failure(let error) = result {
                        return error
                    }
                    return nil
                }
                if errors.isEmpty {
                    return .success(batches)
                }
                return .failure(KafkaError.multiple(errors))
            }
        case .rebalancing(rebalanceFuture: let future):
            logger.info("Group is rebalancing, parking poll() until the rebalance is completed")
            return future.flatMap {
                self.poll(configuration: configuration)
            }
        default:
            logger.error("Poll called, but the consumer is not in the .consuming state")
            return eventLoop.makeFailedFuture(KafkaError.invalidState)
        }
    }

    func fetchOffsets(coordinator: BrokerConnection, partitions: [Topic: [PartitionIndex]]) -> EventLoopFuture<[OffsetFetchResponse.OffsetFetchResponseTopic]> {
        if logger.logLevel >= .debug {
            let partitionDescriptions = partitions.map { (topic, partitions) -> String in
                return "\(topic) (\(partitions.map{String($0)}.joined(separator: ", ")))"
            }
            logger.info("Fetching offsets for topics: \(partitionDescriptions)")
        }

        let requests = partitions.map { (topic, partitions) in
            OffsetFetchRequest.OffsetFetchRequestTopic(
                name: topic,
                                        partitionIndexes: partitions.map {Int32($0)}
                                        )
        }
        return coordinator.requestOffsetFetch(topics: requests,
                                              groupID: configuration.groupID).map { response in
            self.logger.info("Fetched offsets")
            return response.topics
        }
    }


    /// Configures a `NodeConsumer`, connecting to each broker that has at least one partition that the Consumer needs to consume from.
    ///
    /// The consumer uses the `clusterClient` to get/create connections to each broker that is holds a partition of interest.
    ///
    /// - Parameters:
    ///   - partitions: A dictionary of all partitions, keyed by their topic name node consumers need to be configured for.
    ///   - messageHandler: A closure invoked for each consumed message.
    /// - Returns: Future that succeeds with an array of all `NodeConsumer` instances when they have been created.
    private func setupNodeConsumers(consumerCoordinator: ConsumerCoordinator) -> EventLoopFuture<[NodeConsumer]> {
        logger.debug("Configuring NodeConsumers")
        // Get the partitions for each node
        var assignmentsPerNode : [NodeID: [Topic: [PartitionIndex]]] = [:]
        for (topic, partitionInfos) in consumerCoordinator.offsets {
            partitionInfos.forEach {partitionInfo in
                guard let node = self.clusterClient.clusterMetadata.nodeID(forTopic: topic, partition: partitionInfo.key) else {
                    fatalError()
                }
                var nodeAssignments = assignmentsPerNode[node] ?? [:]
                var partitions = nodeAssignments[topic] ?? []
                partitions.append(partitionInfo.value.partition)
                nodeAssignments[topic] = partitions
                assignmentsPerNode[node] = nodeAssignments
            }
        }

        let nodeConsumers = assignmentsPerNode.map { (nodeID, assignments) in
            self.clusterClient.connection(forNode: nodeID).map { connection in
                NodeConsumer(connection: connection,
                             partitions: assignments,
                             consumerCoordinator: consumerCoordinator,
                             configuration: self.configuration,
                             group: self.configuration.groupID,
                             eventLoop: self.eventLoop)
            }
        }
        return EventLoopFuture.whenAllSucceed(nodeConsumers, on: self.eventLoop)
    }


    func joinKnownGroup(groupCoordinator: BrokerConnection, memberID: String) -> EventLoopFuture<Void> {
        self.joinGroup(groupCoordinator: groupCoordinator, memberID: memberID)
            .flatMap { groupInfo in
                self.syncGroup(groupInfo: groupInfo)
                    .flatMap { assignment in
                        self.fetchOffsets(groupInfo: groupInfo, assignment: assignment)
                            .flatMap { offsets in
                                let coordinator = ConsumerCoordinator(partitions: offsets, groupInfo: groupInfo, logger: self.logger)
                                return self.setupNodeConsumers(consumerCoordinator: coordinator).map { consumers in
                                    self.state = .consuming(groupInfo: groupInfo, consumers: consumers, consumerCoordinator: coordinator)
                                }
                            }
                    }

            }
    }


    public func setup() -> EventLoopFuture<Void> {
        findGroupCoordinator(groupID: self.configuration.groupID)
            .flatMap { groupCoordinator in
                self.joinGroupInitial(groupCoordinator: groupCoordinator)
                    .flatMap { memberID in
                        self.joinKnownGroup(groupCoordinator: groupCoordinator, memberID: memberID)
                    }

            }
    }




    /// Shuts down the consumer, returning an event loop future when consuming stopped.
    /// When the consumer is not in the .consuming state, the event loop future will fail with `ProtocolError.invalidState`
    public func shutdown() -> EventLoopFuture<Void> {
        logger.info("Shutting down consumer")
        guard case .consuming(groupInfo: _, consumers: let nodeConsumers, consumerCoordinator: let coordinator) = state else {
            return self.eventLoop.makeFailedFuture(KafkaError.invalidState)
        }


        // Stop all NodeConsumers
        return EventLoopFuture.andAllComplete(nodeConsumers.map { $0.shutdown() }, on: self.eventLoop)
            .flatMap { _ in
                // Commit all current offsets
                switch self.configuration.autoCommit {
                case .off:
                    return self.eventLoop.makeSucceededFuture(())
                case .interval(amount: _):
                    return coordinator.commitOffsets()
                }

            }
            .flatMap {
                coordinator.leaveGroup()
            }
            .flatMap {
                self.clusterClient.closeAllConnections()
            }
            .flatMap {
                coordinator.shutdown()
            }
    }


    private func findGroupCoordinator(groupID: String) -> EventLoopFuture<BrokerConnection> {
        clusterClient.connectionForAnyNode()
            .flatMap { (connection) -> EventLoopFuture<FindCoordinatorResponse> in
                self.logger.info("Trying to find coordinator for group: \(groupID)")
                return connection.requestFindCoordinator(key: groupID, type: .group)
            }.flatMap { (response) -> EventLoopFuture<BrokerConnection> in
                self.logger.info("Found coordinator for group: \(groupID): \(response.nodeID)")
                return self.clusterClient.createConnection(forNode: response.nodeID)
            }
    }






    // MARK: Heartbeat

    var heartbeatRepeatedTask: RepeatedTask?

    func setupHeartbeatScheduler() {
        heartbeatRepeatedTask = eventLoop.scheduleRepeatedAsyncTask(initialDelay: .seconds(0),
                                                                    delay: .seconds(1)) { _ in
            self.heartbeat()
        }
    }
    func removeHeartbeatScheduler() {
        if let repeatedTask = heartbeatRepeatedTask {
            repeatedTask.cancel()
        }
        heartbeatRepeatedTask = nil
    }
    func heartbeat() -> EventLoopFuture<Void> {
        logger.info("Sending heartbeat")
        guard case .consuming(groupInfo: let groupInfo, consumers: _, consumerCoordinator: _) = state else {
            logger.debug("Heartbeat executed in a non consuming state, ignoring")
            return eventLoop.makeSucceededFuture(())
        }
        return groupInfo.coordinator.requestHeartbeat(groupID: groupInfo.groupID,
                                               generationID: groupInfo.generationID,
                                               memberID: groupInfo.memberID)
            .flatMap { response in
                switch response.errorCode {
                case .rebalanceInProgress:
                    return self.rebalance()
                default:
                    return self.eventLoop.makeSucceededFuture(())
                }

            }
    }

}


extension OffsetFetchResponse.OffsetFetchResponseTopic.OffsetFetchResponsePartition {
    var partitionInfo: PartitionInfo {
        PartitionInfo(partition: Int(partitionIndex),
                      currentLeaderEpoch: self.committedLeaderEpoch ?? 0,
                      fetchOffset: max(self.committedOffset, 0),
                      logStartOffset: self.committedOffset)
    }
}
