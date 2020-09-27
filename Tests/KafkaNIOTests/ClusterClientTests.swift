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

        let client1 = try clusterClient.connection(forNode: 1).wait()
        let client2 = try clusterClient.connection(forNode: 2).wait()
        let client3 = try clusterClient.connection(forNode: 3).wait()

        // Test that the client returns the same connection for an established connection
        //
        // The `localAddress` on the channel includes the port which is unique


        XCTAssertEqual(client1.channel.localAddress,
                       try clusterClient.connection(forNode: 1).wait().channel.localAddress)
        XCTAssertEqual(client2.channel.localAddress,
                       try clusterClient.connection(forNode: 2).wait().channel.localAddress)
        XCTAssertEqual(client3.channel.localAddress,
                       try clusterClient.connection(forNode: 3).wait().channel.localAddress)
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
                    if let localAddress = client1.channel.localAddress {
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


struct TestableBroker: BrokerProtocol {

    enum TestableBrokerError: Error {
        case notImplemented
        case foo
    }
    var host: String

    var port: Int

    var rack: String?

    func connect(on eventLoop: EventLoop, clientID: String, tlsConfiguration: TLSConfiguration?) -> EventLoopFuture<BrokerConnection> {
        eventLoop.makeFailedFuture(TestableBrokerError.notImplemented)
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
        ClusterClient(clientID: clientID, eventLoopGroup: eventLoopGroup, clusterMetadata: initalMetadata, tlsConfiguration: nil)
    }
}

class ClusterClientTests: XCTestCase {
    func testConnectionForUnknownNode() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup.init(numberOfThreads: System.coreCount)
        let testBroker = TestableBroker(host: "test-broker1", port: 0, rack: nil)
        let metadata = TestableMetadata(clusterID: "test-cluster", controllerID: 1, brokers: [1: testBroker], topics: [])
        let client = ClusterClient.testable(eventLoopGroup: eventLoopGroup, clientID: "test-cluster", initalMetadata: metadata)

        XCTAssertThrowsError(try client.connection(forNode: 1).wait(), "Expected to fail because the test client doesn't implement connection creation") { (error) in
            XCTAssertEqual(error as! TestableBroker.TestableBrokerError, TestableBroker.TestableBrokerError.notImplemented)
        }
    }
}
