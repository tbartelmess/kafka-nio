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


extension MetadataResponse {
    static func testableTopic(name: Topic, partitionCount: Int) -> MetadataResponseTopic {

        let partitions = (0..<partitionCount).map {
            MetadataResponseTopic.MetadataResponsePartition(errorCode: .noError,
                                                            partitionIndex: Int32($0),
                                                            leaderID: 0,
                                                            leaderEpoch: 0,
                                                            replicaNodes: [],
                                                            isrNodes: [],
                                                            offlineReplicas: [])
        }
        return MetadataResponseTopic(errorCode: .noError,
                                     name: name,
                                     isInternal: false,
                                     partitions: partitions,
                                     topicAuthorizedOperations: 0)
    }
}

class StickyPartitionerCacheTests: XCTestCase {

    let topicA = "topicA"
    let topicB = "topicB"
    let topicC = "topicC"


    var clusterMetadata: TestableMetadata!
    override func setUp() {
        self.clusterMetadata = TestableMetadata(clusterID: "test-cluster", controllerID: 1,
                                                brokers: [:],
                                                topics: [])
    }

    func testStickyPartitionerUnknownPartition() {
        let stickyPartitionCache = StickyPartitionerCache()
        XCTAssertEqual(stickyPartitionCache.partition(for: "unknown", clusterMetadata: clusterMetadata), -1)
    }

    func testStickyPartitionCache() {
        let stickyPartitionCache = StickyPartitionerCache()
        clusterMetadata.topics = [MetadataResponse.testableTopic(name: topicA, partitionCount: 5)]
        let partitionA = stickyPartitionCache.partition(for: topicA, clusterMetadata: clusterMetadata)
        XCTAssertNotEqual(partitionA, -1)
        XCTAssertLessThanOrEqual(partitionA, 4)

        // Assert that the same partition is returned until `nextPartition` is called
        XCTAssertEqual(stickyPartitionCache.partition(for: topicA, clusterMetadata: clusterMetadata), partitionA)

        // Trigger next partition
        let _ = stickyPartitionCache.nextPartition(for: topicA, clusterMetadata: clusterMetadata, previousPartition: partitionA)
        let partitionB = stickyPartitionCache.partition(for: topicA, clusterMetadata: clusterMetadata)
        XCTAssertNotEqual(partitionA, partitionB)

    }
}
