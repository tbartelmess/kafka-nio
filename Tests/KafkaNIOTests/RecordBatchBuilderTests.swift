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

class RecordBatchBuilderTests: XCTestCase {
    func testEmpty() throws {
        let builder = RecordBatchBuilder()
        var buffer = builder.build()
        XCTAssertEqual(buffer.readableBytes, 61)

        let decodedBatch = try RecordBatch(from: &buffer,
                                           topic: "test",
                                           partitionIndex: 1,
                                           crcValidation: true)
        XCTAssertEqual(decodedBatch.baseOffset, 0)
        XCTAssertEqual(decodedBatch.magic, .v2)
        XCTAssertEqual(decodedBatch.crc, 0xFFFFFFFF)
        XCTAssertEqual(decodedBatch.firstTimestamp, 0)
        XCTAssertEqual(decodedBatch.maxTimestamp, 0)
        XCTAssertEqual(decodedBatch.producerID, 0)
        XCTAssertEqual(decodedBatch.producerEpoch, 0)
        XCTAssertEqual(decodedBatch.baseSequence, 0)
        XCTAssertTrue(decodedBatch.records.isEmpty)
    }
}
