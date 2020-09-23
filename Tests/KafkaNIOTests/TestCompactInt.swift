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

import Foundation
import XCTest
import NIO
@testable import KafkaNIO



class CompactIntTests: XCTestCase {
    let allocator = ByteBufferAllocator()

    func assertUnsignedVarintSerde<T: UnsignedInteger>(_ value: T, _ bytes:[UInt8]) throws {
        var buffer = allocator.buffer(capacity: 32)
        buffer.writeVarint(value)
        var expectedBuffer = allocator.buffer(bytes: bytes)
        assertBufferContentsAreEqual(a: &buffer, b: &expectedBuffer)
        var readBuffer = ByteBufferAllocator().buffer(bytes: bytes)
        let readValue: UInt64 = try readBuffer.readVarInt()
        XCTAssertEqual(UInt64(value), readValue)
    }

    func assertUnsignedVarintSerde<T: SignedInteger>(_ value: T, _ bytes:[UInt8]) throws {
        var writeBuffer = allocator.buffer(capacity: 32)
        writeBuffer.writeVarint(value)
        var expectedBuffer = allocator.buffer(bytes: bytes)
        assertBufferContentsAreEqual(a: &writeBuffer, b: &expectedBuffer)


        var readBuffer = ByteBufferAllocator().buffer(bytes: bytes)
        let readValue: T = try readBuffer.readVarInt()
        XCTAssertEqual(value, readValue)
    }

    func testUnsignedVarint() throws {
        try assertUnsignedVarintSerde(UInt(0), [0x00]);
        try assertUnsignedVarintSerde(UInt(1), [0x01]);
        try assertUnsignedVarintSerde(UInt(63), [0x3F]);
        try assertUnsignedVarintSerde(UInt(64), [0x40]);
        try assertUnsignedVarintSerde(UInt(8191), [0xFF, 0x3F]);
        try assertUnsignedVarintSerde(UInt(8192), [0x80, 0x40]);
        try assertUnsignedVarintSerde(UInt(1048575), [0xFF, 0xFF, 0x3F]);
        try assertUnsignedVarintSerde(UInt(1048576), [0x80, 0x80, 0x40]);
        try assertUnsignedVarintSerde(UInt32.max, [0xFF, 0xFF, 0xFF, 0xFF, 0x0F]);
        try assertUnsignedVarintSerde(UInt32(Int32.max), [0xFF, 0xFF, 0xFF, 0xFF, 0x07]);
    }
}
