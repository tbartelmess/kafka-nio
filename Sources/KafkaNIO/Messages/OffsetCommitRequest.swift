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
//
// This file is auto generated from the Kafka Protocol definition. DO NOT EDIT.

import NIO


struct OffsetCommitRequest: KafkaRequest { 
    struct OffsetCommitRequestTopic: KafkaRequestStruct {
        struct OffsetCommitRequestPartition: KafkaRequestStruct {
        
            
            /// The partition index.
            let partitionIndex: Int32    
            /// The message offset to be committed.
            let committedOffset: Int64    
            /// The leader epoch of this partition.
            let committedLeaderEpoch: Int32?    
            /// The timestamp of the commit.
            let commitTimestamp: Int64?    
            /// Any associated metadata the client wants to keep.
            let committedMetadata: String?
            let taggedFields: [TaggedField] = []
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 8) ? .varint : .bigEndian
                buffer.write(partitionIndex)
                buffer.write(committedOffset)
                if apiVersion >= 6 {
                    guard let committedLeaderEpoch = self.committedLeaderEpoch else {
                        throw KafkaError.missingValue
                    }
                    buffer.write(committedLeaderEpoch)
                }
                if apiVersion >= 1 && apiVersion <= 1 {
                    guard let commitTimestamp = self.commitTimestamp else {
                        throw KafkaError.missingValue
                    }
                    buffer.write(commitTimestamp)
                }
                buffer.write(committedMetadata, lengthEncoding: lengthEncoding)
                if apiVersion >= 8 {
                    buffer.write(taggedFields)
                }
            
            }
        }
    
        
        /// The topic name.
        let name: String    
        /// Each partition to commit offsets for.
        let partitions: [OffsetCommitRequestPartition]
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 8) ? .varint : .bigEndian
            buffer.write(name, lengthEncoding: lengthEncoding)
            try buffer.write(partitions, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 8 {
                buffer.write(taggedFields)
            }
        
        }
    }
    let apiKey: APIKey = .offsetCommit
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The unique group identifier.
    let groupID: String
    
    /// The generation of the group.
    let generationID: Int32?
    
    /// The member ID assigned by the group coordinator.
    let memberID: String?
    
    /// The unique identifier of the consumer instance provided by end user.
    let groupInstanceID: String?
    
    /// The time period in ms to retain the offset.
    let retentionTimeMs: Int64?
    
    /// The topics to commit offsets for.
    let topics: [OffsetCommitRequestTopic]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 8) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(groupID, lengthEncoding: lengthEncoding)
        if apiVersion >= 1 {
            guard let generationID = self.generationID else {
                throw KafkaError.missingValue
            }
            buffer.write(generationID)
        }
        if apiVersion >= 1 {
            guard let memberID = self.memberID else {
                throw KafkaError.missingValue
            }
            buffer.write(memberID, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 7 {
            buffer.write(groupInstanceID, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 2 && apiVersion <= 4 {
            guard let retentionTimeMs = self.retentionTimeMs else {
                throw KafkaError.missingValue
            }
            buffer.write(retentionTimeMs)
        }
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 8 {
            buffer.write(taggedFields)
        }
    }
}
