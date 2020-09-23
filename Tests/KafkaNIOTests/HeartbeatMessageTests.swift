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

extension ByteBuffer {
    func hexDump(at: Int, length: Int) -> String {
        let octetsPerRow = 16
        let data = self.getBytes(at: at, length: length)!
        var start = 0
        var output = ""
        while start < data.count {
            let end = start + octetsPerRow
            let slice = data[start..<min(end, length)]
            start+=octetsPerRow
            let line = slice.reduce("") { (result, byte) -> String in
                result + String(format: "%02x ", byte)
            }
            output += line + "\n"

        }
        return output
    }
}

extension XCTestCase {
    func assertBufferContentsAreEqual(a: inout ByteBuffer, b: inout ByteBuffer) {
        XCTAssertEqual(a.readableBytes, b.readableBytes, "The buffers are not equal. A has \(a.readableBytes) bytes, B has \(b.readableBytes) bytes. Hex dump a: \n\(a.hexDump(at: 0, length: a.readableBytes)) \n Hex dump b:\n\(b.hexDump(at: 0, length: b.readableBytes))")
    }
}
class HeartbeatMessageTests: XCTestCase {
    func testGeneration() throws {
        var buffer = try ByteBuffer.from(fixture: "heartbeat-request-v4")
        let request = HeartbeatRequest(apiVersion: 4,
                                       clientID: "consumer-console-consumer-59056-1",
                                       correlationID: 49,
                                       groupID: "console-consumer-59056",
                                       generationID: 327,
                                       memberID: "consumer-console-consumer-59056-1-5b28f454-91fb-4216-b4b2-b886993cfd1a",
                                       groupInstanceID: nil)
        var outputBuffer = ByteBufferAllocator().buffer(capacity: 0)
        try request.write(into: &outputBuffer)
        assertBufferContentsAreEqual(a: &buffer, b: &outputBuffer)
    }
}
