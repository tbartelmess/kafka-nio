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

class Connect: XCTestCase {

    override class func setUp() {
        try? ZookeeperController.shared.startZookeeper()
        try? KafkaController.shared.startKafka()

    }
    override class func tearDown() {
        KafkaController.shared.stopKafka()
        ZookeeperController.shared.stopZookeeper()
    }

    func testConnect() throws {
        var tlsConfiguration = TLSConfiguration.forClient()
        tlsConfiguration.certificateVerification = CertificateVerification.none
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let consumer = try Consumer.connect(configuration: .init(bootstrapServers: [SocketAddress.makeAddressResolvingHost("127.0.0.1", port: 9092)],
                                                                 subscribedTopics: [],
                                                                 groupID: "test",
                                                                 sessionTimeout: 10000,
                                                                 rebalanceTimeout: 10000,
                                                                 tlsConfiguration: nil),
                                            eventLoopGroup: eventLoopGroup).wait()
        XCTAssertEqual(consumer.clusterClient.clusterMetadata.brokers.count, 1)
    }

}

