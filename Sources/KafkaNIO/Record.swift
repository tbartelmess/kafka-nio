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
import Foundation
import CRC32CNIOSupport

enum CompressionAlgorithm: Int8, ProtocolEnum {
    case none = 0
    case gzip = 1
    case snappy = 2
    case lz4 = 3
    case zstd = 4
}


enum CRCValidation {
    case correct
    case incorrect

}
struct RecordBatchOptions {
}

public struct RecordBatch {
    let baseOffset: Int64
    let batchLength: Int32
    let partitionLeaderEpoch: Int32
    let magic: Magic
    let crc: UInt32
    let attributes: Int16
    //let compressionAlgorithm: CompressionAlgorithm
    let lastOffsetDelta: Int32
    let firstTimestamp: Int64
    let maxTimestamp: Int64
    let producerID: Int64
    let producerEpoch: Int16
    let baseSequence: Int32
    public let records: [Record]

    let topic: String
    let partitionIndex: PartitionIndex

    init(from buffer: inout ByteBuffer, topic: String, partitionIndex: PartitionIndex, crcValidation: Bool) throws {
        self.topic = topic
        self.partitionIndex = partitionIndex

        baseOffset = try buffer.read()
        batchLength = try buffer.read()
        if (Int(batchLength) - MemoryLayout<Int64>.size + MemoryLayout<Int32>.size) > buffer.readableBytes {
            throw KafkaError.notEnoughBytes
        }
        partitionLeaderEpoch = try buffer.read()
        magic = try buffer.read()
        crc = try buffer.read()

        if crcValidation {
            let dataSoFar = (MemoryLayout<Int32>.size + MemoryLayout<Int8>.size + MemoryLayout<UInt32>.size)
            guard buffer.crc32(at: buffer.readerIndex, length: Int(batchLength) - dataSoFar) == crc else {
                throw KafkaError.crcValidationFailed
            }
        }
        attributes  = try buffer.read()
        lastOffsetDelta = try buffer.read()
        firstTimestamp = try buffer.read()
        maxTimestamp = try buffer.read()
        producerID = try buffer.read()
        producerEpoch = try buffer.read()
        baseSequence = try buffer.read()



        records = try buffer.read()
    }
}

extension RecordBatch {
    /// The "magic" values for Record Batches
    enum Magic: UInt8, ProtocolEnum {
        case v0 = 0
        case v1 = 1
        case v2 = 2

        static let current = Magic.v2
    }
}

public struct Record {
    public struct Header {
        public var key: String
        public  var value: [UInt8]?

    }
    var length: Int64
    var attributes: Int64
    var timestampDelta: Int
    var offsetDelta: Int
    public var key: [UInt8]?
    public var value: [UInt8]?
    public var headers: [Header]?

    public var data: Data? {
        guard let bytes = value else {
            return nil
        }
        return Data(bytes)
    }

    public var utf8String: String? {
        guard let data = data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

}
extension Record.Header: RawDecodable {

    init(from buffer: inout ByteBuffer) throws {
        key = try buffer.read(lengthEncoding: .varint)
        value = try buffer.read(lengthEncoding: .varint)
    }
}

extension Record: RawDecodable {
    init(from buffer: inout ByteBuffer) throws {
        length = try buffer.read(encoding: .varint)
        attributes = try buffer.read(encoding: .varint)
        timestampDelta = try buffer.read(encoding: .varint)
        offsetDelta = try buffer.read(encoding:  .varint)

        let keyLength: Int = try buffer.readVarInt()
        key = buffer.readBytes(length: keyLength)

        let valueLength: Int = try buffer.readVarInt()
        value = buffer.readBytes(length: valueLength)

        headers = try buffer.read(lengthEncoding: .varint)
    }
}
