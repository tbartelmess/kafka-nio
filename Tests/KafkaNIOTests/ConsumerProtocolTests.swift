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

func AssertEqualAfterSerializationAndDeserialzation<T>(_ value: T, file: StaticString = #file, line: UInt = #line) where T: RawEncodable, T: RawDecodable, T: Equatable{
    do {
        let deserialized = try T.init(from: value.data())
        XCTAssertEqual(deserialized, value,
                       file: file, line: line)
        } catch {
        XCTFail("Failed to deserialize message: \(error)", file: file, line: line)
    }
}


class ConsumerProtocolTests: XCTestCase {
    func testAssignmentSerialization() throws {
        let assignment = Assignment(partitions: [TopicPartition("topic-1", 0)], userData: [])
        AssertEqualAfterSerializationAndDeserialzation(assignment)
    }

    func testAssignmentSerializationOneTopicMuliplePartitions() throws {
        let assignment = Assignment(partitions: [TopicPartition("topic-1", 0), TopicPartition("topic-1", 1), TopicPartition("topic-1", 2)], userData: [])
        AssertEqualAfterSerializationAndDeserialzation(assignment)
    }
}
