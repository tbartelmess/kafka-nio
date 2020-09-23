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


class APIVersions: XCTestCase {
    func testGeneration() throws {
        var buffer = try ByteBuffer.from(fixture: "api-versions-v3")
        let request = ApiVersionsRequest(apiVersion: 3, clientID: "consumer-console-consumer-18117-1", correlationID: 1, clientSoftwareName: "apache-kafka-java", clientSoftwareVersion: "2.6.0")
        var outputBuffer = ByteBufferAllocator().buffer(capacity: 0)
        try request.write(into: &outputBuffer)
        assertBufferContentsAreEqual(a: &buffer, b: &outputBuffer)
    }

    func testParsing() throws {
        var buffer = try ByteBuffer.from(fixture: "api-versions-v3-response")
        let response = try ApiVersionsResponse(from: &buffer, responseHeader: .init(correlationID: 1, version: .v1), apiVersion: 3)
        XCTAssertEqual(response.errorCode, .noError)
        XCTAssertEqual(response.apiKeys.count, APIKey.allCases.count)
    }
}
