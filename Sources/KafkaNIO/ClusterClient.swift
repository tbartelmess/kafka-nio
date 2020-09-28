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

import NIO
import NIOSSL
import Logging

typealias NodeID = Int32

let logger = Logger(label: "io.bartelmess.KafkaNIO.Client")

protocol BrokerProtocol {
    var host: String { get }
    var port: Int { get }
    var rack: String? { get }

    func connect(on eventLoop: EventLoop, clientID: String, tlsConfiguration: TLSConfiguration?, logger: Logger) -> EventLoopFuture<BrokerConnectionProtocol>
}

struct Broker: BrokerProtocol {
    let host: String
    let port: Int
    let rack: String?

    init?(_ socketAddress: SocketAddress, rack: String? = nil) {
        guard let ip = socketAddress.ipAddress,
              let port = socketAddress.port else {
            return nil
        }
        self.host = ip
        self.port = port
        self.rack = rack
    }

    init(host: String, port: Int, rack: String? = nil) {
        self.host = host
        self.port = port
        self.rack = rack
    }
}

enum ClientError: Error {
    case noBootstrapServer
    case serverError(ErrorCode)
}


extension Broker {
    func connect(on eventLoop: EventLoop, clientID: String, tlsConfiguration: TLSConfiguration?, logger: Logger) -> EventLoopFuture<BrokerConnectionProtocol> {
        let messageCoder = KafkaMessageCoder()
        let bootstrap = ClientBootstrap(group: eventLoop)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)

        return bootstrap.connect(host: host, port: port).flatMap { channel in

            var setupTLSFuture: EventLoopFuture<Void>

            if let tlsConfiguration = tlsConfiguration {
                do {
                    let context = try NIOSSLContext(configuration: tlsConfiguration)
                    let tlsHandler = try NIOSSLClientHandler(context: context, serverHostname: nil)
                    setupTLSFuture = channel.pipeline.addHandler(tlsHandler)
                } catch {
                    setupTLSFuture = eventLoop.makeFailedFuture(error)
                }
            } else {
                setupTLSFuture = eventLoop.makeSucceededFuture(())
            }

            return setupTLSFuture.flatMap {
                channel.pipeline.addHandlers([
                   MessageToByteHandler(messageCoder),
                   ByteToMessageHandler(messageCoder)
                ]).flatMap {
                    let connection = try! BrokerConnection(clientID: clientID, channel: channel, logger: logger)
                    return connection.setup ()
                        .map { connection }
                }
            }


        }
    }
}


protocol ClusterMetadataProtocol: CustomStringConvertible {
    var clusterID: String? {get}
    var controllerID: Int32 {get}
    var brokers: [NodeID: BrokerProtocol] {get}
    var topics: [MetadataResponse.MetadataResponseTopic] {get}

    func nodeID(forTopic topic: String, partition: Int) -> NodeID?
}

extension ClusterMetadataProtocol {
    var description: String {
        return "CusterMetadata: <ClusterID:\(clusterID ?? "Unknown") ControllerID:\(controllerID)>"
    }

    func nodeID(forTopic topic: String, partition: Int) -> NodeID? {
        topics.first(where: {$0.name == topic})?.partitions.first(where: {$0.partitionIndex == partition})?.leaderID
    }
}

struct ClusterMetadata: ClusterMetadataProtocol, CustomStringConvertible {
    let clusterID: String?
    let controllerID: Int32
    let brokers: [NodeID: BrokerProtocol]
    let topics: [MetadataResponse.MetadataResponseTopic]


    init(metadata: MetadataResponse) {
        self.clusterID = metadata.clusterID
        self.controllerID = metadata.controllerID ?? 0
        self.brokers = Dictionary(uniqueKeysWithValues: metadata.brokers.map { brokerInfo in
            (brokerInfo.nodeID,
             Broker(host: brokerInfo.host,
                    port: Int(brokerInfo.port),
                    rack: brokerInfo.rack))
        })
        self.topics = metadata.topics
    }
}

class Bootstrapper {
    var servers: [BrokerProtocol]
    let eventLoop: EventLoop
    let tlsConfiguration: TLSConfiguration?
    let logger: Logger
    let clientID: String

    init(servers: [Broker], clientID: String, eventLoop: EventLoop, tlsConfiguration: TLSConfiguration?, logger: Logger = .init(label: "io.bartelmess.NIOKafka.Bootstrap")) {
        self.servers = servers
        self.clientID = clientID
        self.tlsConfiguration = tlsConfiguration
        self.eventLoop = eventLoop
        self.logger = logger
    }

    func nextServer() throws -> BrokerProtocol {
        guard let server = servers.popLast() else {
            throw ClientError.noBootstrapServer
        }
        return server
    }

    func bootstrap() -> EventLoopFuture<BrokerConnectionProtocol> {
        logger.info("Starting Bootstrap to \(servers.count) Server")
        return bootstrapRecursive()
    }

    private func bootstrapRecursive() -> EventLoopFuture<BrokerConnectionProtocol> {
        let promise = eventLoop.makePromise(of: BrokerConnectionProtocol.self)
        do {
            let broker = try nextServer()
            logger.info("Attempting to bootstrap with Server: \(broker.host):\(broker.port)")
            broker.connect(on: eventLoop, clientID: clientID, tlsConfiguration: tlsConfiguration, logger: logger)
                .flatMapError { _ in
                    return self.bootstrapRecursive()
                }
                .cascade(to: promise)
        } catch {
            promise.fail(error)
        }
        return promise.futureResult
    }
}
enum MetadataRefresh {
    case manual
    case automatic(TimeAmount)
}

/// Connection pool for a cluster.
///
/// There is one `BrokerConnectionProtocol` to each Node in the broker cluster.
/// Each `BrokerConnectionProtocol` runs on it's own `EventLoop`
final class ClusterClient {
    /// Event Loop Group to generate new `EventLoop`s from
    private let eventLoopGroup: EventLoopGroup

    /// EventLopp of the ClusterClient. The cluster client itself doesn't use perfrom IO, but it uses it's own event loop for scheduling
    /// metadata refreshes and to submit tasks that run on multiple event loops.
    private let eventLoop: EventLoop

    private let logger: Logger

    /// The current cluster metadata
    var clusterMetadata: ClusterMetadataProtocol

    /// TLS configuration to use when establishing new connections to new brokers
    var tlsConfiguration: TLSConfiguration?

    /// Client ID of the the broker. This for logging purposes on the broker.
    let clientID: String

    /// A list of current connections.
    ///
    /// When a new connection to a broker is needed that does not exist yet, a future to setup the broker connection is added,
    /// in most cases the futures in this dictionary will already be fulfilled, when a connection exists.
    /// __Thread Safety:__ This variable is private to the `ClusterClient`, the cluster client only adds/removes
    /// elements within it's own event loop
    private var connectionFutures: [NodeID: EventLoopFuture<BrokerConnectionProtocol>] = [:]

    /// Promise that gets fulfilled when the next metadata fetch is updated
    private var nextMetadataRefresh: EventLoopPromise<Void>

    /// List of topics the `ClusterClient` keeps metadata for.
    private var topics: Set<String>

    func addTopic(topic: String) {
        topics.insert(topic)
        let _ = eventLoop.flatSubmit(doMetadataRefresh)
    }

    func removeTopic(topic: String) {
        topics.insert(topic)
        let _ = eventLoop.flatSubmit(doMetadataRefresh)
    }

    /// Create a new cluster from a set of servers.
    /// At least one the servers needs to be reachable. During the bootstrap the we try to connection to each server in a sequential order
    /// the first server where the connection suceeds is used to discover the rest of the cluster.
    /// - Parameters:
    ///   - servers: lists of brokers that can be used to bootstrap
    ///   - eventLoopGroup: `EventLoopGroup` that is used for creating new `EventLoop` instances.
    ///                     Both the `ClusterClient`s own `EventLoop` as well as all `BrokerConnectionProtocol`s
    ///                     that are created will use event loops from this `EventLoopGroup`
    ///   - clientID: ClientID to report to Kafka
    ///   - tlsConfiguration: TLSConfiguration for connections to the Kafka cluster created by this ClusterClient
    ///   - topics: A list of topics the ClusterClient should maintain metadata about
    /// - Returns: `EventLoopFuture` that gets fulfilled after the bootstrap finsihed and the initial metadata is fetched from the cluster.
    static func bootstrap(servers: [Broker],
                          eventLoopGroup: EventLoopGroup,
                          clientID: String,
                          tlsConfiguration: TLSConfiguration?,
                          topics: [Topic] = [],
                          logger: Logger = .init(label: "io.bartelmess.KafkaNIO")) -> EventLoopFuture<ClusterClient> {
        Bootstrapper(servers: servers, clientID: clientID, eventLoop: eventLoopGroup.next(), tlsConfiguration: tlsConfiguration, logger: logger)
            .bootstrap()
            .flatMap { (bootstrapConnection) in
                bootstrapConnection.requestFetchMetadata(topics: topics).map { ($0, bootstrapConnection) }
            }.map { (response, connection) -> (ClusterClient, BrokerConnectionProtocol) in
                let initalMetadata = ClusterMetadata(metadata: response)

                return (ClusterClient(clientID: clientID, eventLoopGroup: eventLoopGroup, clusterMetadata: initalMetadata, topics: topics, tlsConfiguration: tlsConfiguration, logger: logger), connection)
            }.flatMap { clusterClient, connection in
                connection.close().map { clusterClient }
            }
    }

    init(clientID: String, eventLoopGroup: EventLoopGroup, clusterMetadata: ClusterMetadataProtocol, topics:[Topic], tlsConfiguration: TLSConfiguration?, logger: Logger, metadataRefresh: MetadataRefresh = .automatic(TimeAmount.seconds(10))) {
        self.clientID = clientID
        self.eventLoopGroup = eventLoopGroup
        self.clusterMetadata = clusterMetadata
        self.tlsConfiguration = tlsConfiguration
        self.eventLoop = eventLoopGroup.next()
        self.topics = Set(topics)
        self.logger = logger
        nextMetadataRefresh = eventLoop.makePromise()
        if case .automatic(let interval) = metadataRefresh {
            configurePeriodicRefresh(interval: interval)
        }

    }

    deinit {
        // Suceed the nextMetadata promise, otherwise it'll "leak".
        nextMetadataRefresh.succeed(())
    }

    func connectionForAnyNode() -> EventLoopFuture<BrokerConnectionProtocol> {
        guard let connectionFuture = connectionFutures.randomElement() else {
            guard let nodeID = clusterMetadata.brokers.keys.randomElement() else {
                return eventLoop.makeFailedFuture(KafkaError.noKnownNode)
            }
            return connection(forNode: nodeID)
        }
        return connectionFuture.value
    }

    /// Creates a connection to a node, but doesn't store a reference to the connection for reuse.
    func createConnection(forNode nodeID: NodeID) -> EventLoopFuture<BrokerConnectionProtocol> {
        eventLoop.flatSubmit {
            guard let brokerInfo = self.clusterMetadata.brokers[nodeID] else {
                return self.eventLoop.makeFailedFuture(KafkaError.unknownNodeID)
            }
            return brokerInfo.connect(on: self.eventLoopGroup.next(),
                                      clientID: self.clientID,
                                      tlsConfiguration: self.tlsConfiguration,
                                      logger: self.logger)
        }
    }
    /// Returns a `BrokerConnectionProtocol` for a NodeID.
    ///
    /// The node must be part of the cluster, otherwise the future fails with `ProtocolError.unknownNodeID`
    func connection(forNode nodeID: NodeID) -> EventLoopFuture<BrokerConnectionProtocol> {
        eventLoop.flatSubmit {
            guard let brokerInfo = self.clusterMetadata.brokers[nodeID] else {
                return self.eventLoop.makeFailedFuture(KafkaError.unknownNodeID)
            }
            if let connectionFuture = self.connectionFutures[nodeID] {
                return connectionFuture
            }
            let future = brokerInfo.connect(on: self.eventLoopGroup.next(), clientID: self.clientID,
                                            tlsConfiguration: self.tlsConfiguration,
                                            logger: self.logger)
            self.connectionFutures[nodeID] = future
            return future
        }
    }

    func closeConnection(forNode nodeID: NodeID) -> EventLoopFuture<Void> {
        guard let connectionFuture = connectionFutures[nodeID] else {
            return eventLoop.makeSucceededFuture(())
        }
        connectionFutures.removeValue(forKey: nodeID)
        return connectionFuture.flatMap { $0.close() }
    }

    func closeAllConnections() -> EventLoopFuture<Void> {
        let closeFutures = self.connectionFutures.keys.map { self.closeConnection(forNode: $0) }
        return EventLoopFuture.andAllComplete(closeFutures, on: self.eventLoop)
    }


    var metadataRefreshTask: RepeatedTask?

    func doMetadataRefresh() -> EventLoopFuture<Void> {
        self.connectionForAnyNode().flatMap { connection in
            self.refreshMetadata(connection: connection)
        }
    }

    func configurePeriodicRefresh(interval: TimeAmount) {
        metadataRefreshTask = eventLoop.scheduleRepeatedAsyncTask(initialDelay: interval, delay: interval) { repeatedTask in
            self.doMetadataRefresh()
        }
    }


    func refreshMetadata(connection: BrokerConnectionProtocol) -> EventLoopFuture<Void> {
        connection.requestFetchMetadata(topics: Array(self.topics)).map { response in
            self.eventLoop.execute {
                self.clusterMetadata = ClusterMetadata(metadata: response)
                self.nextMetadataRefresh.succeed(())
                self.nextMetadataRefresh = self.eventLoop.makePromise()
            }
        }

    }

    func nodeIDAfterNextMetadataRefresh(forTopic topic: String, partition: Int, attempts: Int = 5) -> EventLoopFuture<NodeID> {
        if attempts == 0 {
            return eventLoop.makeFailedFuture(KafkaError.nodeForTopicNotFound)
        }

        return nextMetadataRefresh.futureResult.flatMap {
            guard let nodeID = self.clusterMetadata.nodeID(forTopic: topic, partition: partition) else {
                return self.nodeIDAfterNextMetadataRefresh(forTopic: topic, partition: partition, attempts: attempts-1)
            }
            return self.eventLoop.makeSucceededFuture(nodeID)
        }
    }

    /// Ensure that the metadata for the given topics is available, when metadata for a topic in the list is not available
    /// (e.g. due to a `.leaderNotAvailable`) the metadata will be refreshed up to `attempts` times, if the metadata is still not available,
    /// the future will fail.
    func ensureHasMetadataFor(topics: [Topic], attempts: Int = 5) -> EventLoopFuture<Void> {
        if attempts == 0 {
            return eventLoop.makeFailedFuture(KafkaError.missingMetadata)
        }
        let missingTopics = topics.filter { topicName in
            !(clusterMetadata.topics.contains { $0.name == topicName })
        }
        let missingMetadata = clusterMetadata.topics.filter { topic in
            topic.errorCode != .noError
        }
        if missingTopics.isEmpty && missingMetadata.isEmpty {
            return eventLoop.makeSucceededFuture(())
        }

        return nextMetadataRefresh.futureResult.flatMap{
            self.ensureHasMetadataFor(topics: topics, attempts: attempts - 1)
        }
    }

    func nodeID(forTopic topic: String, partition: Int) -> EventLoopFuture<NodeID> {
        guard let nodeID = self.clusterMetadata.nodeID(forTopic: topic, partition: partition) else {
            return nodeIDAfterNextMetadataRefresh(forTopic: topic, partition: partition)
        }
        return eventLoop.makeSucceededFuture(nodeID)
    }


}
