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

class RecordBatchAttributesTests: XCTestCase {
    func testCompressionAlgorithmRoundTrip(algorithm: CompressionAlgorithm, expected: Int16) throws {
        let attributes = RecordBatch.Attributes(compressionAlgorithm: algorithm,
                                                timestampType: .createTime,
                                                transactional: false,
                                                controlBatch: false)
        XCTAssertEqual(attributes.attributesValue, expected)

        let parsed = try RecordBatch.Attributes(value: attributes.attributesValue)
        XCTAssertEqual(parsed.compressionAlgorithm, algorithm)
    }

    func testCompressionAlgorithmNone() throws {
        try testCompressionAlgorithmRoundTrip(algorithm: .none, expected: 0)
    }

    func testCompressionAlgorithmGZip() throws {
        try testCompressionAlgorithmRoundTrip(algorithm: .gzip, expected: 1)
    }

    func testCompressionAlgorithmSnappy() throws {
        try testCompressionAlgorithmRoundTrip(algorithm: .snappy, expected: 2)
    }

    func testCompressionAlgorithmLZ4() throws {
        try testCompressionAlgorithmRoundTrip(algorithm: .lz4, expected: 3)
    }

    func testCompressionAlgorithmZStd() throws {
        try testCompressionAlgorithmRoundTrip(algorithm: .zstd, expected: 4)
    }

    func testCompressionAlgorithmInvalid() throws {
        XCTAssertThrowsError(try RecordBatch.Attributes(value: 0x5),
                             "0x6 is not a valid compression algorithm") { error in
            guard let kafkaError = error as? KafkaError else {
                XCTFail("Expected a KafkaError")
                return
            }
            XCTAssertTrue(kafkaError == .invalidCompressionAlgorithm)
        }
    }

    func testTimestampType() throws {
        let expectedAttributesCreateTime = RecordBatch.Attributes(compressionAlgorithm: .none,
                                                                  timestampType: .createTime,
                                                                  transactional: false,
                                                                  controlBatch: false)
        let expectedAttributesAppendTime = RecordBatch.Attributes(compressionAlgorithm: .none,
                                                                  timestampType: .appendTime,
                                                                  transactional: false,
                                                                  controlBatch: false)

        let expectedValueCreateTime: Int16 = 0
        let expectedValueAppendTime: Int16 = 0x8
        XCTAssertEqual(try RecordBatch.Attributes(value: expectedValueCreateTime), expectedAttributesCreateTime)
        XCTAssertEqual(try RecordBatch.Attributes(value: expectedValueAppendTime), expectedAttributesAppendTime)
        XCTAssertEqual(expectedAttributesCreateTime.attributesValue, expectedValueCreateTime)
        XCTAssertEqual(expectedAttributesAppendTime.attributesValue, expectedValueAppendTime)
    }

    func testTransactionalFlag() throws {
        let nonTransactional = RecordBatch.Attributes(compressionAlgorithm: .none,
                                                           timestampType: .createTime,
                                                           transactional: false,
                                                           controlBatch: false)
        let transactional = RecordBatch.Attributes(compressionAlgorithm: .none,
                                                   timestampType: .createTime,
                                                   transactional: true,
                                                   controlBatch: false)
        let transactionalValue: Int16 = 0x10
        let nonTransactionalValue: Int16 = 0x0
        XCTAssertEqual(try RecordBatch.Attributes(value: transactionalValue), transactional)
        XCTAssertEqual(try RecordBatch.Attributes(value: nonTransactionalValue), nonTransactional)
        XCTAssertEqual(nonTransactional.attributesValue, nonTransactionalValue)
        XCTAssertEqual(transactional.attributesValue, transactionalValue)
    }
}
