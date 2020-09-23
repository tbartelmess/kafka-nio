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


import NIO

extension ByteBuffer {


    mutating func write(_ value: [UInt8], lengthEncoding: IntegerEncoding) {
        writeArrayLength(length: value.count, lengthEncoding: lengthEncoding)
        value.forEach { writeInteger($0) }
    }
    mutating func write(_ value: [[UInt8]], lengthEncoding: IntegerEncoding) {
        fatalError("Not implemented")
    }

    mutating func read(lengthEncoding: IntegerEncoding = .bigEndian) throws -> [UInt8] {
        let size: Int = try self.readArrayLength(lengthEncoding: lengthEncoding)
        guard let data = readBytes(length: Int(size)) else {
            throw KafkaError.notEnoughBytes
        }
        return data
    }



    mutating func read(lengthEncoding: IntegerEncoding = .bigEndian) throws -> [UInt8]? {
        let size = try self.readArrayLength(lengthEncoding: lengthEncoding)
        if size == -1 {
            return nil
        }
        guard let data = readBytes(length: Int(size)) else {
            throw KafkaError.notEnoughBytes
        }
        return data
    }

}
