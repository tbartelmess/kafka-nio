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
@testable import KafkaNIO

final class RangeAssignorTests: XCTestCase {
    var assignor = RangeAssignor.self

    func testOneConsumerNoTopic() {
        let partitionsPerTopic: [String: Int] = [:]
        let subscriptions = [
            "consumer1" : Subscription(topics: [], userData: [], ownedPartitions: [])
        ]
        let assignments = assignor.assign(partitionsPerTopic: partitionsPerTopic,
                                          subscriptions: subscriptions)
        // Expect one assingment because the group has one consumer
        XCTAssertEqual(assignments.count, 1)
        guard let consumer1Assignment = assignments["consumer1"] else {
            XCTFail("Assignments don't contain an assignment for 'consumer1'")
            return
        }
        XCTAssertTrue(consumer1Assignment.isEmpty)
    }

    func testOneConsumerOneTopic() {
        let partitionsPerTopic: [String: Int] = ["topic1": 1]
        let subscriptions = [
            "consumer1" : Subscription(topics: ["topic1"], userData: [], ownedPartitions: [])
        ]
        let assignments = assignor.assign(partitionsPerTopic: partitionsPerTopic,
                                          subscriptions: subscriptions)
        XCTAssertEqual(assignments.count, 1)
        guard let consumer1Assignment = assignments["consumer1"] else {
            XCTFail("Assignments don't contain an assignment for 'consumer1'")
            return
        }
        XCTAssertEqual(consumer1Assignment, [TopicPartition("topic1", 0)])
    }

    func testOneConsumerOneTopicMultiplePartitions() {
        let partitionsPerTopic: [String: Int] = ["topic1": 3]
        let subscriptions = [
            "consumer1" : Subscription(topics: ["topic1"], userData: [], ownedPartitions: [])
        ]
        let assignments = assignor.assign(partitionsPerTopic: partitionsPerTopic,
                                          subscriptions: subscriptions)
        XCTAssertEqual(assignments.count, 1)
        guard let consumer1Assignment = assignments["consumer1"] else {
            XCTFail("Assignments don't contain an assignment for 'consumer1'")
            return
        }
        XCTAssertEqual(consumer1Assignment, [TopicPartition("topic1", 0),
                                             TopicPartition("topic1", 1),
                                             TopicPartition("topic1", 2)])
    }


    func testOnlyAssignsPartitionsFromSubscribedTopics() {

    }

    func testOneConsumerNonexistentTopic() {
        
    }
}
