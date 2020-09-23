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


enum IntegerEncoding {
    case bigEndian
    case varint
}

protocol ProtocolEnum: RawRepresentable, RawEncodable {}
extension ProtocolEnum where RawValue: FixedWidthInteger & SignedInteger {
    func write(into buffer: inout ByteBuffer) {
        buffer.write(self.rawValue)
    }
}
extension ProtocolEnum where RawValue: FixedWidthInteger & UnsignedInteger {
    func write(into buffer: inout ByteBuffer) {
        buffer.write(self.rawValue)
    }
}
extension ByteBuffer {




    // MARK: Protocol Enum

    mutating func read<T: ProtocolEnum>() throws -> T where T.RawValue: FixedWidthInteger & UnsignedInteger {
        let raw: T.RawValue = try self.read()
        guard let value = T(rawValue: raw) else {
            throw KafkaError.invalidEnumValue
        }
        return value
    }

    // MARK: Strings


    mutating func writeNullableString(_ value: String?) {
        writeInteger(Int16(value?.utf8.count ?? -1))
        if let string = value {
            writeString(string)
        }
    }

    mutating func writeCompactString(_ value: String?) {

        guard let string = value else {
            writeVarint(UInt(0))
            return
        }
            writeVarint(UInt(string.utf8.count + 1 ))
            writeString(string)

    }

    mutating func writeCompactString(_ value: String) {
        writeVarint(UInt(value.utf8.count) + 1)
        writeString(value)
    }

    mutating func writeCompactStringArray(_ value: [String]) {
        writeVarint(value.count)
        value.forEach { writeCompactString($0) }
    }

    mutating func writeStringArray(_ values: [String]) {
        writeInteger(Int32(values.count))
        values.forEach { write($0) }
    }

    mutating func writeStringArray(_ values: [String]?) {
        guard let values = values else {
            writeInteger(Int32(-1))
            return
        }

        writeStringArray(values)
    }





    mutating func write(_ value: [[UInt8]]) {
        fatalError("Not implemented")
    }


    mutating func writeKafkaBytes(_ data: [UInt8]) {
        writeInteger(Int32(data.count), endianness: .big, as: Int32.self)
        writeBytes(data)
    }

    mutating func writeKafkaBytes(_ data: [UInt8]?) {
        guard let data = data else {
            writeInteger(Int32(-1), endianness: .big, as: Int32.self)
            return
        }
        writeInteger(Int32(data.count), endianness: .big, as: Int32.self)
        writeBytes(data)
    }



    mutating func read() throws -> Float64 {
        fatalError("Not implemented")
    }

    mutating func write(_ value: Float64) {
        fatalError("Not implemented")
    }

    mutating func write(_ value: Bool) {
        self.writeBytes([value ? 1 : 0])
    }

    mutating func read() throws -> Bool {
        guard let byte = readBytes(length: 1)?.first else {
            throw KafkaError.notEnoughBytes
        }
        return byte != 0 ? true : false
    }


    mutating func read<T: RawDecodable>(lengthEncoding: IntegerEncoding = .bigEndian) throws -> [T] {
        let size: Int32 = try read(encoding: lengthEncoding)
        var result: [T] = []
        for _ in 0..<size {
            result.append(try T.init(from: &self))
        }
        return result
    }
    mutating func read<T: RawDecodable>(lengthEncoding: IntegerEncoding = .bigEndian) throws -> [T]? {
        let size: Int32 = try read(encoding: lengthEncoding)
        if size < 0 {
            return nil
        }
        var result: [T] = []
        for _ in 0..<size {
            result.append(try T.init(from: &self))
        }
        return result
    }

    mutating func write<T: RawEncodable>(_ values: [T]) {
        writeInteger(Int32(values.count), endianness: .big, as: Int32.self)
        values.forEach { $0.write(into: &self) }
    }



    mutating func write<T: RawEncodable>(_ value: T) {
        value.write(into: &self)
    }

    mutating func read<T: RawDecodable>() throws -> T {
        return try T.init(from: &self)
    }

    mutating func write<T: KafkaRequestStruct>(_ value: T, apiVersion: APIVersion) throws {
        try value.write(into: &self, apiVersion: apiVersion)
    }

    mutating func write<T: KafkaRequestStruct>(_ values: [T], apiVersion: APIVersion, lengthEncoding: IntegerEncoding = .bigEndian) throws {
        writeArrayLength(length: values.count, lengthEncoding: lengthEncoding)
        try values.forEach { try $0.write(into: &self, apiVersion: apiVersion) }
    }

    mutating func write<T: KafkaRequestStruct>(_ values: [T]?, apiVersion: APIVersion, lengthEncoding: IntegerEncoding = .bigEndian) throws {
        guard let values = values else {
            writeArrayLength(length: -1, lengthEncoding: lengthEncoding)
            return
        }
        try write(values, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }

    mutating func read<T: KafkaResponseStruct>(apiVersion: APIVersion) throws -> T {
        return try T(from: &self, apiVersion: apiVersion)
    }

    @inline(__always)
    private mutating func readArray<T: KafkaResponseStruct>(apiVersion: APIVersion, size: Int) throws -> [T] {
        var result: [T] = []
        for _ in 0..<size {
            result.append(try T.init(from: &self, apiVersion: apiVersion))
        }
        return result
    }

    mutating func read<T: KafkaResponseStruct>(apiVersion: APIVersion, lengthEncoding: IntegerEncoding = .bigEndian) throws -> [T] {
        let size = try readArrayLength(lengthEncoding: lengthEncoding)
        return try readArray(apiVersion: apiVersion, size: size)

    }

    mutating func read<T: KafkaResponseStruct>(apiVersion: APIVersion, lengthEncoding: IntegerEncoding = .bigEndian) throws -> [T]? {
        let size = try readArrayLength(lengthEncoding: lengthEncoding)
        if size < 0 {
            return nil
        }
        return try readArray(apiVersion: apiVersion, size: size)
    }

}

protocol RawDecodable {
    init(from buffer: inout ByteBuffer) throws
}

protocol KafkaResponseStruct {
    init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws
}

protocol KafkaRequestStruct {
    func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws
}

protocol RawEncodable {
    func write(into buffer: inout ByteBuffer)
}

extension RawEncodable {
    func data() throws -> [UInt8] {
        var buffer = ByteBufferAllocator().buffer(capacity: 0)
        buffer.write(self)
        return buffer.readBytes(length: buffer.readableBytes) ?? []
    }
}

extension RawDecodable {
    init(from data: [UInt8]) throws {
        var buffer = ByteBufferAllocator().buffer(capacity: data.count)
        buffer.writeBytes(data)
        try self.init(from: &buffer)
    }
}

extension String: RawDecodable {
    init(from buffer: inout ByteBuffer) throws {
        self = try buffer.read()
    }
}
