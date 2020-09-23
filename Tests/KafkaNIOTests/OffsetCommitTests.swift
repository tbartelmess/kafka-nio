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


class OffsetCommitTests: XCTestCase {

    func testParsingVersion3() throws {
        var buffer = try ByteBuffer.from(fixture: "commit-offsets-v3-response")
        let header = try KafkaResponseHeader.read(from: &buffer, correlationID: 1, version: APIKey.offsetCommit.responseHeaderVersion(for: 3))

        let response = try OffsetCommitResponse(from: &buffer, responseHeader: header, apiVersion: 3)

        XCTAssertEqual(response.throttleTimeMs, 0)
        XCTAssertEqual(response.topics.count, 1)
        guard let topic = response.topics.first else {
            XCTFail("Expected one topic")
            return
        }
        XCTAssertEqual(topic.name, "test-topic-2")
        XCTAssertEqual(topic.partitions.count, 1)
        guard let partition = topic.partitions.first else {
            XCTFail("Expected one partition")
            return
        }
        XCTAssertEqual(partition.errorCode, .noError)
        XCTAssertEqual(partition.partitionIndex, 0)
    }
}
