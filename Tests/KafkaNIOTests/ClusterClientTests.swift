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

import XCTest
import NIO
import NIOSSL
import Logging
@testable import KafkaNIO


class ClusterClientOnlineTests: XCTestCase {
    let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    var clusterClient: ClusterClient!
    override func setUpWithError() throws {
        clusterClient = try ClusterClient.bootstrap(servers: [Broker(host: "kafka-01.bartelmess.io",
                                                     port: 9092,
                                                     rack: nil)],
                                                    eventLoopGroup: eventLoopGroup,
                                                    clientID: "unit-tests",
                                                    tlsConfiguration: nil).wait()
    }

    func testGetAll() throws {


        XCTAssertEqual(clusterClient.clusterMetadata.brokers.keys.count, 3)

        let client1 = try clusterClient.connection(forNode: 1).wait() as? BrokerConnection
        let client2 = try clusterClient.connection(forNode: 2).wait() as? BrokerConnection
        let client3 = try clusterClient.connection(forNode: 3).wait() as? BrokerConnection

        // Test that the client returns the same connection for an established connection
        //
        // The `localAddress` on the channel includes the port which is unique


        XCTAssertEqual(client1?.channel.localAddress,
                       (try clusterClient.connection(forNode: 1).wait() as? BrokerConnection)?.channel.localAddress)
        XCTAssertEqual(client2?.channel.localAddress,
                       (try clusterClient.connection(forNode: 2).wait() as? BrokerConnection)?.channel.localAddress)
        XCTAssertEqual(client3?.channel.localAddress,
                       (try clusterClient.connection(forNode: 3).wait() as? BrokerConnection)?.channel.localAddress)
    }

    func testConcurrentAccess() {
        var client1Addresses: [SocketAddress] = []

        let queue = DispatchQueue(label: "io.bartelmess.KafkaNIO.test", attributes: .concurrent)
        queue.suspend()
        let concurrency = 10
        let expectations = (0..<concurrency).map { invocation in
            self.expectation(description: "Request client \(invocation+1)/10")
        }
        for invocation in 0..<10 {
            queue.async {
                do {
                    let client1 = try self.clusterClient.connection(forNode: 1).wait()
                    if let localAddress = (client1 as? BrokerConnection)?.channel.localAddress {
                        client1Addresses.append(localAddress)
                    }
                } catch {
                    XCTFail(error.localizedDescription)
                }
                expectations[invocation].fulfill()
            }
        }
        queue.resume()
        wait(for: expectations, timeout: 10, enforceOrder: false)
        XCTAssertEqual(Set(client1Addresses.map {$0.description} ).count, 1)
    }
}

struct Queue<T> {
    var elements: [T] = []

    mutating func enqueue(_ element: T) {
        elements.insert(element, at: 0)
    }

    mutating func dequeue() -> T? {
        elements.popLast()
    }
}



class TestableBrokerConnection: BrokerConnectionProtocol {

    enum TestableBrokerConnectionError: Error {
        case noResponseEnqueued
    }

    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }


    var eventLoop: EventLoop
    var supportedVersions: [APIKey: APIVersion] = [:]

    var queuedResponses: [APIKey: Queue<KafkaResponse>] = [:]

    func send<R>(_ request: KafkaRequest) -> EventLoopFuture<R> where R : KafkaResponse {
        guard let response = queuedResponses[request.apiKey]?.dequeue() as? R else {
            return eventLoop.makeFailedFuture(TestableBrokerConnectionError.noResponseEnqueued)
        }
        return eventLoop.makeSucceededFuture(response)
    }

    func enqueueResponse<T>(_ response: T, forKey key: APIKey) where T : KafkaResponse {
        if queuedResponses[key] == nil {
            queuedResponses[key] = Queue()
        }
        queuedResponses[key]?.enqueue(response)
    }

    var correlationID: CorrelationID = 0

    func nextCorrectionID() -> CorrelationID {
        correlationID += 1
        return correlationID
    }

    func close() -> EventLoopFuture<Void> {
        return eventLoop.makeSucceededFuture(())
    }

    func latestSupportedVersion(for key: APIKey) -> APIVersion? {
        return supportedVersions[key]
    }

    var clientID: String = "test-client"


}

struct TestableBroker: BrokerProtocol {

    enum TestableBrokerError: Error {
        case notImplemented
        case foo
    }
    var host: String

    var port: Int

    var rack: String?

    func connect(on eventLoop: EventLoop, clientID: String, tlsConfiguration: TLSConfiguration?, logger: Logger) -> EventLoopFuture<BrokerConnectionProtocol> {
        return eventLoop.makeSucceededFuture(TestableBrokerConnection(eventLoop: eventLoop))
    }


}

struct TestableMetadata: ClusterMetadataProtocol {
    var clusterID: String?

    var controllerID: Int32

    var brokers: [NodeID : BrokerProtocol]

    var topics: [MetadataResponse.MetadataResponseTopic]


}

extension ClusterClient {
    static func testable(eventLoopGroup: EventLoopGroup,
                         clientID: String,
                         initalMetadata: TestableMetadata) -> ClusterClient {
        ClusterClient(clientID: clientID,
                      eventLoopGroup: eventLoopGroup,
                      clusterMetadata: initalMetadata,
                      topics: [],
                      tlsConfiguration: nil,
                      logger: Logger(label: "test-logger"),
                      metadataRefresh: .manual)
    }
}

class ClusterClientTests: XCTestCase {
    let eventLoopGroup = MultiThreadedEventLoopGroup.init(numberOfThreads: System.coreCount)
    let testBroker = TestableBroker(host: "test-broker1", port: 0, rack: nil)
    var testBrokerConnection: TestableBrokerConnection!
    var client: ClusterClient!

    override func setUpWithError() throws {
        let metadata = TestableMetadata(clusterID: "test-cluster", controllerID: 1, brokers: [1: testBroker], topics: [])
        client = ClusterClient.testable(eventLoopGroup: eventLoopGroup, clientID: "test-cluster", initalMetadata: metadata)
        testBrokerConnection = try client.connection(forNode: 1).wait() as? TestableBrokerConnection
    }


    func testRefreshMetadata() throws {

        testBrokerConnection.supportedVersions[APIKey.apiVersions] = 3
        testBrokerConnection.supportedVersions[APIKey.metadata] = 9
        testBrokerConnection.enqueueResponse(MetadataResponse(apiVersion: 9,
                                                        responseHeader: .init(correlationID: 1, version: .v1),
                                                        throttleTimeMs: 0,
                                                        brokers: [.init(nodeID: 1, host: "test-broker", port: 0, rack: nil)],
                                                        clusterID: "test-cluster",
                                                        controllerID: 1,
                                                        topics: [],
                                                        clusterAuthorizedOperations: nil), forKey: .metadata)
        try client.doMetadataRefresh().wait()
        XCTAssertEqual(client.clusterMetadata.controllerID, 1)
        XCTAssertEqual(client.clusterMetadata.brokers.count, 1)
        XCTAssertEqual(client.clusterMetadata.topics.count, 0)

        testBrokerConnection.enqueueResponse(MetadataResponse(apiVersion: 9,
                                                        responseHeader: .init(correlationID: 1, version: .v1),
                                                        throttleTimeMs: 0,
                                                        brokers: [.init(nodeID: 1, host: "test-broker", port: 0, rack: nil)],
                                                        clusterID: "test-cluster",
                                                        controllerID: 1,
                                                        topics: [.init(errorCode: .noError, name: "my-topic", isInternal: false, partitions: [.init(errorCode: .noError, partitionIndex: 1, leaderID: 1, leaderEpoch: 1, replicaNodes: [], isrNodes: [], offlineReplicas: [])], topicAuthorizedOperations: 0)],
                                                        clusterAuthorizedOperations: nil), forKey: .metadata)
        try client.doMetadataRefresh().wait()
        XCTAssertEqual(client.clusterMetadata.controllerID, 1)
        XCTAssertEqual(client.clusterMetadata.brokers.count, 1)
        XCTAssertEqual(client.clusterMetadata.topics.count, 1)
        guard let topic = client.clusterMetadata.topics.first else {
            XCTFail("topics in clusterMetadata is empty")
            return
        }
        XCTAssertEqual(topic.name, "my-topic")
        XCTAssertEqual(topic.errorCode, .noError)
        XCTAssertEqual(topic.partitions.count, 1)
        XCTAssertEqual(topic.partitions.first?.leaderID, 1)
    }

    func testConnectionForTopic() throws {
        testBrokerConnection.supportedVersions[APIKey.apiVersions] = 3
        testBrokerConnection.supportedVersions[APIKey.metadata] = 9
        testBrokerConnection.enqueueResponse(MetadataResponse(apiVersion: 9,
                                                        responseHeader: .init(correlationID: 1, version: .v1),
                                                        throttleTimeMs: 0,
                                                        brokers: [.init(nodeID: 1, host: "test-broker", port: 0, rack: nil)],
                                                        clusterID: "test-cluster",
                                                        controllerID: 1,
                                                        topics: [.init(errorCode: .leaderLeaderNotAvailable, name: "my-topic", isInternal: false, partitions: [], topicAuthorizedOperations: 0)],
                                                        clusterAuthorizedOperations: nil), forKey: .metadata)
        try client.doMetadataRefresh().wait()
        
    }
}
