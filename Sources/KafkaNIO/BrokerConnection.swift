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
import Logging
import NIOConcurrencyHelpers


private struct Queue<T> {
    var elements: [T] = []
    var lock = Lock()

    mutating func enqueue(_ element: T) {
        lock.withLock {
            elements.insert(element, at: 0)
        }
    }

    mutating func dequeue() -> T? {
        lock.withLock {
            elements.popLast()
        }
    }
}
private typealias CorrelationID = Int32
/// The `BrokerConnection` is a connection to one specific broker in the Kafka cluster.
/// It owns the NIO `Channel` with the underlying TCP connecting and offers a high level interface
/// to send messages to the broker.
final public class BrokerConnection {

    /// NIO channel.
    let channel: Channel

    /// Logger for the broker connection
    public let logger: Logger

    /// List of supported API versions by the cluster
    private var supportedAPIVersion: [(APIKey, APIVersion, APIVersion)] = []

    private func latestSupportedVersion(for key: APIKey) -> APIVersion? {
        supportedAPIVersion.first { (_key, _, _) -> Bool in
            key == _key
        }?.2
    }

    private var parkedResponsePromises: [CorrelationID: EventLoopPromise<KafkaResponse>] = [:]

    init(clientID: String, channel: Channel, logger: Logger) throws {
        self.clientID = clientID
        self.channel = channel
        self.logger = logger
    }

    func close() -> EventLoopFuture<Void> {
        logger.info("Closing connection to: \(self.channel.remoteAddress?.description ?? "<Unknown>")")
        return self.channel.close()
    }

    func configureChannel() -> EventLoopFuture<Void> {
        logger.debug("Configuring Channel: \(self)")
        let messageHandler = KafkaResponseHandler(responseHandler: self.handleResponse)
        return channel.pipeline.addHandler(messageHandler, name: "connection", position: .last)
    }
    func handleResponse(_ message: KafkaResponse) {
        logger.trace("Received \(message) from \(channel.remoteAddress?.ipAddress ?? "Unknown address")")
        guard let responsePromise = self.parkedResponsePromises[message.responseHeader.correlationID] else {
            logger.critical("Received a message without a promise to fulfil.")
            return
        }
        responsePromise.succeed(message)
    }

    private var lastCorrelationID: CorrelationID = 0

    let clientID: String


    var correlationLock = Lock()
    private func nextCorrectionID() -> CorrelationID {
        correlationLock.withLock {
            lastCorrelationID += 1
            return lastCorrelationID
        }

    }

    func setup() -> EventLoopFuture<Void> {
        return configureChannel().flatMap {
            self.requestQueryAPIVersions(clientID: self.clientID)
        }.map { response in
            self.supportedAPIVersion = response.apiKeys.map{ ($0.apiKey, $0.minVersion, $0.maxVersion) }
            self.logger.debug("Updated supported API Version")
        }
    }

    let writeLock = Lock()
    func send<R: KafkaResponse>(_ request: KafkaRequest) -> EventLoopFuture<R> {
        logger.trace("Sending \(request.apiKey) to \(channel.remoteAddress?.ipAddress ?? "Unknown Address") with correlationID: \(request.correlationID)")
        let responsePromise = self.channel.eventLoop.makePromise(of: KafkaResponse.self)
        writeLock.withLock {
            parkedResponsePromises[request.correlationID] = responsePromise
            channel.writeAndFlush(request).cascadeFailure(to: responsePromise)
        }

        return responsePromise.futureResult.map { response -> R in
            self.logger.trace("Recieved response for correlationID \(response.responseHeader.correlationID)")
            guard let typedResponse = response as? R else {
                fatalError("Expected response to be a \(R.self) but received a \(type(of: response))")
            }

            return typedResponse
        }
    }



    // MARK: Request APIs

    func requestQueryAPIVersions(clientID: String) -> EventLoopFuture<ApiVersionsResponse> {
        let version = APIVersion(1)
        let request = ApiVersionsRequest(apiVersion: version,
                                         clientID: clientID,
                                         correlationID: nextCorrectionID(),
                                         clientSoftwareName: "kafka-nio",
                                         clientSoftwareVersion: KafkaNIOVersion.string)
        return send(request)
    }

    func requestFetchMetadata(topics: [String],
                       allowAutoTopicCreation: Bool = true,
                       includeClusterAuthorizedOperations: Bool = true,
                       includeTopicAuthorizedOperations: Bool = true) -> EventLoopFuture<MetadataResponse> {
        guard let version = self.latestSupportedVersion(for: .metadata) else {
            fatalError()
        }
        let request = MetadataRequest(apiVersion: version,
                                      clientID: clientID,
                                      correlationID: nextCorrectionID(),
                                      topics: topics.map { MetadataRequest.MetadataRequestTopic(name: $0) },
                                      allowAutoTopicCreation: allowAutoTopicCreation,
                                      includeClusterAuthorizedOperations: includeClusterAuthorizedOperations,
                                      includeTopicAuthorizedOperations: includeTopicAuthorizedOperations)
        return send(request)
    }

    func requestFindCoordinator(key: String, type: CoordinatorType) -> EventLoopFuture<FindCoordinatorResponse> {
        guard let version = self.latestSupportedVersion(for: .findCoordinator) else {
            fatalError()
        }
        let request = FindCoordinatorRequest(apiVersion: version,
                                             clientID: self.clientID,
                                             correlationID: nextCorrectionID(),
                                             key: key,
                                             keyType: type)

        return send(request)
    }

    func requestJoinGroup(groupID: String, topics:[String], sessionTimeout: Int32, rebalanceTimeout: Int32, memberID: String, groupInstanceID: String?) -> EventLoopFuture<JoinGroupResponse> {
        let subscription = Subscription(topics: topics, userData: [], ownedPartitions: []).data()
        guard let version = self.latestSupportedVersion(for: .joinGroup) else {
            fatalError()
        }
        let groupProtocols = [JoinGroupRequest.JoinGroupRequestProtocol(name: "range", metadata: subscription)]
        let request = JoinGroupRequest(apiVersion: version,
                                       clientID: self.clientID,
                                       correlationID: nextCorrectionID(),
                                       groupID: groupID,
                                       sessionTimeoutMs: sessionTimeout,
                                       rebalanceTimeoutMs: rebalanceTimeout,
                                       memberID: memberID,
                                       groupInstanceID: groupInstanceID,
                                       protocolType: "consumer",
                                       protocols: groupProtocols)
        return send(request)
    }

    func requestSyncGroup(groupID: String,
                          generationID: Int32,
                          memberID: String,
                          groupInstanceID: String?,
                          protocolName: String?,
                          assignments:[ConsumerID:Assignment] = [:]) -> EventLoopFuture<SyncGroupResponse>{
        let networkAssignments = assignments.map { assignment in
            SyncGroupRequest.SyncGroupRequestAssignment(memberID: assignment.key, assignment: try! assignment.value.data())
        }
        guard let version = self.latestSupportedVersion(for: .syncGroup) else {
                    fatalError()
                }
        let request = SyncGroupRequest(apiVersion: version,
                                       clientID: self.clientID,
                                       correlationID: nextCorrectionID(),
                                       groupID: groupID,
                                       generationID: generationID,
                                       memberID: memberID,
                                       groupInstanceID: groupInstanceID,
                                       protocolType: "consumer",
                                       protocolName: protocolName,
                                       assignments: networkAssignments)
        return send(request)
    }

    func requestOffsetFetch(topics: [OffsetFetchRequest.OffsetFetchRequestTopic], groupID: String) -> EventLoopFuture<OffsetFetchResponse> {
        guard let version = self.latestSupportedVersion(for: .offsetFetch) else {
            fatalError()
        }
        let request = OffsetFetchRequest(apiVersion: version,
                                         clientID: clientID,
                                         correlationID: nextCorrectionID(),
                                         groupID: groupID,
                                         topics: topics,
                                         requireStable: false)

        return send(request)
    }

    func requestFetch(maxWaitTime: Int,
                      minBytes: Int,
                      maxBytes: Int,
                      isolationLevel: IsolationLevel = .readCommited,
                      sessionID: Int32,
                      sessionEpoch: Int32,
                      topics: [FetchRequest.FetchTopic],
                      forgottenTopics: [FetchRequest.ForgottenTopic] = [],
                      rackID: String = "") -> EventLoopFuture<FetchResponse> {
        guard let version = self.latestSupportedVersion(for: .fetch) else {
                    fatalError()
                }
        let request = FetchRequest(apiVersion: version,
                                   clientID: self.clientID,
                                   correlationID: nextCorrectionID(),
                                   replicaID: -1,
                                   maxWaitMs: Int32(maxWaitTime),
                                   minBytes: Int32(minBytes),
                                   maxBytes: Int32(maxBytes),
                                   isolationLevel: isolationLevel,
                                   sessionID: sessionID,
                                   sessionEpoch: sessionEpoch,
                                   topics: topics,
                                   forgottenTopicsData: forgottenTopics,
                                   rackID: rackID)
        return send(request)
    }

    func requestHeartbeat(groupID: String,
                          generationID: Int32,
                          memberID: String) -> EventLoopFuture<HeartbeatResponse> {
        guard let version = self.latestSupportedVersion(for: .heartbeat) else {
                    fatalError()
                }
        let request = HeartbeatRequest(apiVersion: version,
                                       clientID: clientID,
                                       correlationID: nextCorrectionID(),
                                       groupID: groupID,
                                       generationID: generationID,
                                       memberID: memberID,
                                       groupInstanceID: nil)
        return send(request)
    }

    func requestOffsetCommit(groupID: String,
                             generationID: Int32,
                             memberID: String,
                             topics: [OffsetCommitRequest.OffsetCommitRequestTopic]) -> EventLoopFuture<OffsetCommitResponse> {
        guard let version = self.latestSupportedVersion(for: .offsetCommit) else {
            fatalError()
        }
        let request = OffsetCommitRequest(apiVersion: version,
                                          clientID: clientID,
                                          correlationID: nextCorrectionID(),
                                          groupID: groupID,
                                          generationID: generationID,
                                          memberID: memberID,
                                          groupInstanceID: nil,
                                          retentionTimeMs: 0,
                                          topics: topics)
        return send(request)
    }

    /// The Kakfa API allows for one client to send a leave group request for more than one client.
    /// This API only allows one member to leave
    func requestGroupLeave(groupID: String, memberID: String, groupInstanceID: String?) -> EventLoopFuture<LeaveGroupResponse> {
        guard let version = self.latestSupportedVersion(for: .leaveGroup) else {
                    fatalError()
                }
        let request = LeaveGroupRequest(apiVersion: version,
                                        clientID: self.clientID,
                                        correlationID: nextCorrectionID(),
                                        groupID: groupID,
                                        memberID: memberID,
                                        members: [.init(memberID: memberID, groupInstanceID: groupInstanceID)])
        return send(request)
    }


    func requestOffsets(isolationLevel: IsolationLevel = .readCommited,
                        topics: [ListOffsetRequest.ListOffsetTopic]) -> EventLoopFuture<ListOffsetResponse> {
        guard let version = self.latestSupportedVersion(for: .listOffset) else {
            fatalError()
        }
        let request = ListOffsetRequest(apiVersion: version,
                                        clientID: self.clientID,
                                        correlationID: nextCorrectionID(),
                                        replicaID: -1,
                                        isolationLevel: isolationLevel,
                                        topics: topics)
        return send(request)
    }
}

