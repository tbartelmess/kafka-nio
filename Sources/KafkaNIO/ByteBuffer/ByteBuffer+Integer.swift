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
fileprivate let msb = UInt8(0x80)
fileprivate let lowerBits = ~msb

extension ByteBuffer {
    // MARK: Integers

    mutating func readVarInt<T: UnsignedInteger>() throws -> T {
        var value: T = 0
        var i = 0
        var byte: UInt8 = 0
        while true  {
            guard let readByte: UInt8 = self.readInteger() else {
                throw KafkaError.notEnoughBytes
            }
            byte = readByte

            if byte & 0x80 == 0 {


                break
            }
            value |= T(byte & 0x7f) << i
            i += 7;

        }
        value |= T(byte) << i
        return value
    }

    mutating func readVarInt<T: SignedInteger>() throws -> T {
        let value: UInt64 = try readVarInt()
        return T(Int64(value >> 1) ^ (Int64((value & 1)) * -1))
    }

    mutating func writeVarint<T: UnsignedInteger>(_ value: T) {
        var _value = value
        while _value & 0xffffff80 != 0 {
            let chunk = UInt8(truncatingIfNeeded: UInt(value) & UInt(lowerBits))
            write(chunk)
            _value >>= 7
        }
        write(UInt8(truncatingIfNeeded: UInt(value)))
    }


    mutating func readVarInt<T: FixedWidthInteger & SignedInteger>(_ valueType: T.Type = T.self) throws -> T {
        try readVarInt()
    }


    mutating func readVarInt<T: FixedWidthInteger & UnsignedInteger>(_ valueType: T.Type = T.self) throws -> T {
        try readVarInt()
    }


    mutating func writeVarint<T: SignedInteger>(_ value: T) {
        writeVarint(UInt((value << 1) ^ (value >> 31)))
    }

    // MARK: Values


    mutating func write<T: FixedWidthInteger & UnsignedInteger>(_ value: T, encoding: IntegerEncoding = .bigEndian) {
        switch encoding {
        case .bigEndian:
            writeInteger(value, endianness: .big, as: T.self)
        case .varint:
            writeVarint(value)
        }
    }

    mutating func write<T: FixedWidthInteger & SignedInteger>(_ value: T, encoding: IntegerEncoding = .bigEndian) {
        switch encoding {
        case .bigEndian:
            writeInteger(value, endianness: .big, as: T.self)
        case .varint:
            writeVarint(value)
        }
    }

    mutating func read<T: FixedWidthInteger & UnsignedInteger>(_ valueType: T.Type = T.self, encoding: IntegerEncoding = .bigEndian) throws -> T {
        switch encoding {
        case .bigEndian:
            guard let value = self.readInteger(endianness: .big, as: valueType) else {
                throw KafkaError.notEnoughBytes
            }
            return value
        case .varint:
            return try readVarInt()
        }
    }

    mutating func read<T: FixedWidthInteger & SignedInteger>(_ valueType: T.Type = T.self, encoding: IntegerEncoding = .bigEndian) throws -> T {
        switch encoding {
        case .bigEndian:
            guard let value = self.readInteger(endianness: .big, as: valueType) else {
                throw KafkaError.notEnoughBytes
            }
            return value
        case .varint:
            return try readVarInt()

        }
    }


    // MARK: Arrays

    mutating func write<T: FixedWidthInteger>(_ values: [T], lengthEncoding: IntegerEncoding = .bigEndian) {
        writeArrayLength(length: values.count, lengthEncoding: lengthEncoding)
        values.forEach { writeInteger($0, endianness: .big, as: T.self) }
    }

    mutating func write<T: FixedWidthInteger>(_ values: [T]?, lengthEncoding: IntegerEncoding = .bigEndian) {
        guard let values = values else {
            writeArrayLength(length: -1, lengthEncoding: lengthEncoding)
            return
        }
        write(values)
    }

    mutating func read<T: FixedWidthInteger & UnsignedInteger>(_ valueType: T.Type = T.self, lengthEncoding: IntegerEncoding = .bigEndian) throws -> [T]? {
        let size = try readArrayLength(lengthEncoding: lengthEncoding)
        if size == -1 {
            return nil
        }
        var result: [T] = []
        for _ in 0..<size {
            result.append(try read())
        }
        return result
    }

    mutating func read<T: FixedWidthInteger & UnsignedInteger>(_ valueType: T.Type = T.self, lengthEncoding: IntegerEncoding = .bigEndian) throws -> [T] {
        let size = try readArrayLength(lengthEncoding: lengthEncoding)
        var result: [T] = []
        for _ in 0..<size {
            result.append(try read())
        }
        return result
    }

    mutating func read<T: FixedWidthInteger & SignedInteger>(_ valueType: T.Type = T.self, lengthEncoding: IntegerEncoding = .bigEndian) throws -> [T] {
        let size = try readArrayLength(lengthEncoding: lengthEncoding)
        var result: [T] = []
        for _ in 0..<size {
            result.append(try read())
        }
        return result
    }
}
