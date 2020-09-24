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
@testable import KafkaNIO


class ClusterClientTests: XCTestCase {
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
