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
    /// Write a nullable string into the buffer.
    /// When using `.compact` length encoding writes a string the kafka protocol calls `COMPACT_NULLABLE_STRING`
    mutating func write(_ value: String?, lengthEncoding: IntegerEncoding = .bigEndian) {
        guard let value = value else {
            switch lengthEncoding {
            case .bigEndian:
                writeInteger(-1, endianness: .big, as: Int16.self)
            case .varint:
                writeVarint(UInt(0))
            }
            return
        }
        write(value, lengthEncoding: lengthEncoding)
    }

    mutating func write(_ value: String, lengthEncoding: IntegerEncoding = .bigEndian) {
        switch lengthEncoding {
        case .bigEndian:
            writeInteger(Int16(value.utf8.count), endianness: .big, as: Int16.self)
        case .varint:
            writeVarint(UInt(value.utf8.count + 1))
        }
        writeString(value)
    }

    /// Read a non-null string.
    /// When the `lengthEncoding` is `.varint` the string will be read as a `COMPACT_STRING`, otherwise as `STRING`
    /// as defined in the Kafka protocol spec.
    /// See http://kafka.apache.org/protocol#protocol_types for detials
    mutating func read(lengthEncoding: IntegerEncoding = .bigEndian) throws -> String {
        let size: Int
        switch lengthEncoding {
        case .bigEndian:
            size = Int(try read(encoding: .bigEndian) as Int16)
        default:
            size = Int(try read(encoding: .varint) as UInt) - 1

        }
        guard let string = readString(length: size) else {
            throw KafkaError.notEnoughBytes
        }
        return string

    }

    /// Reads  an optional string
    /// When the `lengthEncoding` is `.varint` the string will be read as `COMPACT_NULLABLE_STRING`, when the `lengthEncoding` is `.bigEndian`
    /// the string will be read a `NULLABLE_STRING`
    mutating func read(lengthEncoding: IntegerEncoding = .bigEndian) throws -> String? {
        let size: Int
        switch lengthEncoding {
        case .bigEndian:
            size = Int(try read(encoding: .bigEndian) as Int16)
        case .varint:
            size = Int(try read(encoding: .varint) as UInt) - 1
        }
        guard size >= 0 else {
            return nil
        }

        guard let string = readString(length: Int(size)) else {
            throw KafkaError.notEnoughBytes
        }
        return string
    }


    // MARK: Arrays




    mutating func write(_ value: [String], lengthEncoding: IntegerEncoding = .bigEndian) {
        fatalError("Not implemented")
    }
    mutating func write(_ value: [String]?, lengthEncoding: IntegerEncoding = .bigEndian) {
        fatalError("Not implemented")
    }

}
