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


class JoinGroupTests: XCTestCase {
    func testGeneration() throws {
        var buffer = try ByteBuffer.from(fixture: "join-group-v7-request")
        let request = JoinGroupRequest(apiVersion: 7,
                                       clientID: "consumer-console-consumer-12414-1",
                                       correlationID: 3,
                                       groupID: "console-consumer-12414",
                                       sessionTimeoutMs: 10000,
                                       rebalanceTimeoutMs: 300000,
                                       memberID: "",
                                       groupInstanceID: nil,
                                       protocolType: "consumer",
                                       protocols: [JoinGroupRequest.JoinGroupRequestProtocol(name: "range",
                                                                                             metadata: [0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x0C, 0x74, 0x65, 0x73, 0x74, 0x2D, 0x74, 0x6F, 0x70, 0x69, 0x63, 0x2D, 0x31, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00])])
        var outputBuffer = ByteBufferAllocator().buffer(capacity: 0)
        try request.write(into: &outputBuffer)
        assertBufferContentsAreEqual(a: &buffer, b: &outputBuffer)
    }

    func testParsingInitial() throws {
        var buffer = try ByteBuffer.from(fixture: "join-group-v7-response-initial")
        let header = try KafkaResponseHeader.read(from: &buffer, correlationID: 1, version: .v1)
        let response = try JoinGroupResponse(from: &buffer, responseHeader: header, apiVersion: 7)
        XCTAssertEqual(response.errorCode, .memberMemberIdRequired)
    }
    func testParsing() throws {
        var buffer = try ByteBuffer.from(fixture: "join-group-v7-response")
        let header = try KafkaResponseHeader.read(from: &buffer, correlationID: 1, version: .v1)
        let response = try JoinGroupResponse(from: &buffer, responseHeader: header, apiVersion: 7)
        XCTAssertEqual(response.errorCode, .noError)
    }
}
