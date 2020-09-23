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


class FetchTests: XCTestCase {

    func testParsingOutOfRange() throws {
        var buffer = try ByteBuffer.from(fixture: "fetch-v11-response-out-of-range")
        let header = try KafkaResponseHeader.read(from: &buffer, correlationID: 1, version: .v0)

        let response = try FetchResponse(from: &buffer, responseHeader: header, apiVersion: 11)
        XCTAssertEqual(response.errorCode, .noError)
    }

    func testParsingAndRecordBufferDecoding() throws {
        var buffer = try ByteBuffer.from(fixture: "fetch-v11-response")
        let header = try KafkaResponseHeader.read(from: &buffer, correlationID: 1, version: .v0)

        let response = try FetchResponse(from: &buffer, responseHeader: header, apiVersion: 11)
        XCTAssertEqual(response.errorCode, .noError)
        guard var recordSetBuffer = response.responses.first?.partitionResponses.first?.recordSet else {
            XCTFail("Not recordSet buffer found in response")
            return
        }
        let batch = try RecordBatch(from: &recordSetBuffer, topic: "test", partitionIndex: 1, crcValidation: true)
        XCTAssertEqual(batch.records.count, 100)
    }


}
