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

/// The `RecordBatchBuilder` builds a `RecordBatch` in memory.
/// The `RecordBatchBuilder` uses a `ByteBuffer` as it's internal storage.
/// It's not allowed read bytes (or move the `readerIndex`) from the buffer. This class expects the
/// reader index to be stable to jump to specifc offsets to update header values (e.g the size and the CRC).
class RecordBatchBuilder {

    private static let allocator = ByteBufferAllocator()

    /// Offsets
    private static let baseOffsetLength = MemoryLayout<Int64>.size

    private static let batchLengthLength = MemoryLayout<Int32>.size
    private static let batchLengthOffset = baseOffsetLength

    private static let partitionLeaderEpochLength = MemoryLayout<Int32>.size
    private static let partitionLeaderEpochOffset = batchLengthOffset + batchLengthLength

    private static let magicLength = MemoryLayout<Int8>.size
    private static let magicOffset = partitionLeaderEpochOffset + partitionLeaderEpochLength

    private static let crcLength = MemoryLayout<Int32>.size
    private static let crcOffset = magicOffset + magicLength

    private static let attributesLength = MemoryLayout<Int16>.size
    private static let attributesOffset = crcOffset + crcLength

    private static let lastOffsetDeltaLength = MemoryLayout<Int32>.size
    private static let lastOffsetDeltaOffset = attributesOffset + attributesLength

    private static let firstTimestampLength = MemoryLayout<Int64>.size
    private static let firstTimestampOffset = lastOffsetDeltaOffset + lastOffsetDeltaLength

    private static let maxTimestampLength = MemoryLayout<Int64>.size
    private static let maxTimestampOffset = firstTimestampOffset + firstTimestampLength

    private static let producerIDLength = MemoryLayout<Int64>.size
    private static let producerIDOffset = maxTimestampOffset + maxTimestampLength

    private static let producerEpochLength = MemoryLayout<Int16>.size
    private static let producerEpochOffset = producerIDOffset + producerIDLength

    private static let baseSequenceLength = MemoryLayout<Int32>.size
    private static let baseSequenceOffset = producerEpochOffset + producerEpochLength

    private static let recordsLengthLength = MemoryLayout<Int32>.size
    private static let recordsLengthOffset = baseSequenceOffset + baseSequenceLength

    private static let checksummedStart = crcOffset + crcLength
    private static let headerLength = recordsLengthOffset + recordsLengthLength
    

    init() {
        buffer = RecordBatchBuilder.allocator.buffer(capacity: RecordBatchBuilder.headerLength)
        startTimestamp = Date().kafkaTimestamp
        buffer.moveWriterIndex(forwardBy: RecordBatchBuilder.headerLength)
    }

    private var startTimestamp: Int
    private var buffer: ByteBuffer
    private var numberOfRecords: Int = 0

    private var crcBufferView: ByteBufferView? {
        buffer.viewBytes(at: RecordBatchBuilder.checksummedStart,
                        length: buffer.readableBytes - RecordBatchBuilder.checksummedStart)
    }

    func append(key: [UInt8], value: [UInt8], headers: [Record.Header]?, timestamp: Int) {
        let offset = self.numberOfRecords
        self.numberOfRecords += 1
        let timestampDelta = startTimestamp - timestamp
        let record = Record(key: key,
                            value: value,
                            headers: headers,
                            timestampDelta: timestampDelta,
                            offsetDelta: offset)
        record.write(into: &self.buffer)
    }


    private func calculateCRC() -> UInt32 {
        buffer.crc32(at: RecordBatchBuilder.checksummedStart, length: buffer.readableBytes - RecordBatchBuilder.crcOffset)
    }

    private func writeHeader() {
        // Write baseOffset
        buffer.setInteger(0 as Int64, at: 0)

        // Buffer set batch length
        buffer.setInteger(0 as Int32, at: RecordBatchBuilder.batchLengthOffset)

        buffer.setInteger(0 as Int32, at: RecordBatchBuilder.partitionLeaderEpochOffset)

        buffer.setInteger(RecordBatch.Magic.current.rawValue, at: RecordBatchBuilder.magicOffset)

        buffer.setInteger(0 as Int16, at: RecordBatchBuilder.attributesLength)

        buffer.setInteger(0 as Int32, at: RecordBatchBuilder.lastOffsetDeltaOffset)

        buffer.setInteger(0 as Int64, at: RecordBatchBuilder.firstTimestampOffset)

        buffer.setInteger(0 as Int64, at: RecordBatchBuilder.maxTimestampOffset)

        buffer.setInteger(0 as Int64, at: RecordBatchBuilder.producerIDOffset)

        buffer.setInteger(0 as Int16, at: RecordBatchBuilder.producerEpochOffset)

        buffer.setInteger(0 as Int32, at: RecordBatchBuilder.baseSequenceOffset)
        
        buffer.setInteger(0 as Int32, at: RecordBatchBuilder.recordsLengthOffset)
        // Write CRC
        buffer.setInteger(calculateCRC(), at: RecordBatchBuilder.crcOffset)
    }

    func build() -> ByteBuffer {
        self.writeHeader()
        return self.buffer
    }
}

public class RecordAccumulator {

    init() {

    }

    private var buffers: [TopicPartition: ByteBuffer] = [:]

    func append(topicPartition: TopicPartition,
                timestamp: Int64,
                key: [UInt8],
                value: [UInt8]) {

    }

    func getBuffer(for topicPartition: TopicPartition) -> ByteBuffer {
        guard let buffer = buffers[topicPartition] else {
            let newBuffer = ByteBufferAllocator().buffer(capacity: 0)
            self.buffers[topicPartition] = newBuffer
            return newBuffer
        }
        return buffer
    }

}
