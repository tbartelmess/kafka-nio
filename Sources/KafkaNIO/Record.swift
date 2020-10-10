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

public enum CompressionAlgorithm: Int8, ProtocolEnum, Equatable {
    case none = 0
    case gzip = 1
    case snappy = 2
    case lz4 = 3
    case zstd = 4
}

public enum TimestampType: Equatable {
    case createTime
    case appendTime
}


/// A container for records.
///
/// A record batch is a container for records. In old versions of the record format (versions 0 and 1),
/// a batch consisted always of a single record if no compression was enabled, but could contain
/// many records otherwise. Newer versions (magic versions 2 and above) will generally contain many records
/// regardless of compression.
public struct RecordBatch {
    /// The offset of the first record in the batch. In magic versions before 2, the base offset will always be
    /// the offset of the first message in the batch. For magic version v2 this is the first offset of the original batch
    /// (before compaction). When the record was not compacted the value is the same as in `v0` and `v1`.

    let baseOffset: Int64

    /// Size in bytes of the batch, including the size of the record and the batch overhead.
    let batchLength: Int32

    /// Partition leader epoch of this record batch. (-1 when unknown)
    let partitionLeaderEpoch: Int32
    let magic: Magic


    let crc: UInt32
    private let attributes: Int16

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
            guard buffer.crc32(at: buffer.readerIndex, length: buffer.readableBytes) == crc else {
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
    /// Attributes of a `RecordBatch`
    public struct Attributes: Equatable {

        /// Compression algorihm used for the `RecordBatch`
        public let compressionAlgorithm: CompressionAlgorithm

        /// Timestamp used in the `RecordBatch`
        public let timestampType: TimestampType

        /// Flag if the batch is a transactional batch
        public let transactional: Bool

        /// Flag weather the batch is a control batch
        ///
        /// See the [Kafka documentation on control batches](https://kafka.apache.org/documentation/#controlbatch) for details.
        public let controlBatch: Bool


        private let compressionAlgorithmMask: Int16 = 0x07
        private let timestampTypeMask: Int16 = 0x8
        private let transactionalMask: Int16 = 0x10
        private let controlFlagMask: Int16 = 0x20

        init(compressionAlgorithm: CompressionAlgorithm,
             timestampType: TimestampType,
             transactional: Bool,
             controlBatch: Bool) {
            self.compressionAlgorithm = compressionAlgorithm
            self.timestampType = timestampType
            self.transactional = transactional
            self.controlBatch = controlBatch
        }


        init(value: Int16) throws {
            guard let compressionAlgorithm = CompressionAlgorithm(rawValue: Int8(value & compressionAlgorithmMask)) else {
                throw KafkaError.invalidCompressionAlgorithm
            }
            self.compressionAlgorithm = compressionAlgorithm
            self.timestampType = (value & timestampTypeMask) == 0 ? .createTime : .appendTime
            self.transactional = value & transactionalMask == transactionalMask
            self.controlBatch = value & controlFlagMask == controlFlagMask
        }

        var attributesValue: Int16 {
            var value: Int16 = 0
            value |= Int16(compressionAlgorithm.rawValue)
            switch timestampType {

            case .createTime:
                // 0 == .createTime
                break
            case .appendTime:
                value |= timestampTypeMask
            }

            if transactional {
                value |= transactionalMask
            }

            if controlBatch {
                value |= controlFlagMask
            }
            return value
        }


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

extension Record.Header: RawEncodable {
    func write(into buffer: inout ByteBuffer) {
        buffer.write(key, lengthEncoding: .varint)
        buffer.write(value, lengthEncoding: .varint)
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

extension Record: RawEncodable {
    func write(into buffer: inout ByteBuffer) {
        var recordBuffer = ByteBuffer()
        recordBuffer.write(attributes, encoding: .varint)
        recordBuffer.write(timestampDelta, encoding: .varint)
        recordBuffer.write(offsetDelta, encoding: .varint)
        recordBuffer.write(key, lengthEncoding: .varint)
        recordBuffer.write(value, lengthEncoding: .varint)
        recordBuffer.write(headers, lengthEncoding: .varint)
        buffer.write(recordBuffer.readableBytes, encoding: .varint)
        buffer.writeBuffer(&recordBuffer)
    }


}

extension Record {
    init(key: [UInt8], value: [UInt8], headers: [Header]?, timestampDelta: Int, offsetDelta: Int) {
        self.key = key
        self.value = value
        self.headers = headers
        self.timestampDelta = timestampDelta
        self.offsetDelta = offsetDelta
        self.attributes = 0
        self.length = 0
    }
}
