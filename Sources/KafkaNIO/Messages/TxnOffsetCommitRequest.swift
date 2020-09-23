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


struct TxnOffsetCommitRequest: KafkaRequest { 
    struct TxnOffsetCommitRequestTopic: KafkaRequestStruct {
        struct TxnOffsetCommitRequestPartition: KafkaRequestStruct {
        
            
            /// The index of the partition within the topic.
            let partitionIndex: Int32    
            /// The message offset to be committed.
            let committedOffset: Int64    
            /// The leader epoch of the last consumed record.
            let committedLeaderEpoch: Int32?    
            /// Any associated metadata the client wants to keep.
            let committedMetadata: String?
            let taggedFields: [TaggedField] = []
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 3) ? .varint : .bigEndian
                buffer.write(partitionIndex)
                buffer.write(committedOffset)
                if apiVersion >= 2 {
                    guard let committedLeaderEpoch = self.committedLeaderEpoch else {
                        throw KafkaError.missingValue
                    }
                    buffer.write(committedLeaderEpoch)
                }
                buffer.write(committedMetadata, lengthEncoding: lengthEncoding)
                if apiVersion >= 3 {
                    buffer.write(taggedFields)
                }
            
            }
        }
    
        
        /// The topic name.
        let name: String    
        /// The partitions inside the topic that we want to committ offsets for.
        let partitions: [TxnOffsetCommitRequestPartition]
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 3) ? .varint : .bigEndian
            buffer.write(name, lengthEncoding: lengthEncoding)
            try buffer.write(partitions, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 3 {
                buffer.write(taggedFields)
            }
        
        }
    }
    let apiKey: APIKey = .txnOffsetCommit
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The ID of the transaction.
    let transactionalID: String
    
    /// The ID of the group.
    let groupID: String
    
    /// The current producer ID in use by the transactional ID.
    let producerID: Int64
    
    /// The current epoch associated with the producer ID.
    let producerEpoch: Int16
    
    /// The generation of the consumer.
    let generationID: Int32?
    
    /// The member ID assigned by the group coordinator.
    let memberID: String?
    
    /// The unique identifier of the consumer instance provided by end user.
    let groupInstanceID: String?
    
    /// Each topic that we want to commit offsets for.
    let topics: [TxnOffsetCommitRequestTopic]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 3) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(transactionalID, lengthEncoding: lengthEncoding)
        buffer.write(groupID, lengthEncoding: lengthEncoding)
        buffer.write(producerID)
        buffer.write(producerEpoch)
        if apiVersion >= 3 {
            guard let generationID = self.generationID else {
                throw KafkaError.missingValue
            }
            buffer.write(generationID)
        }
        if apiVersion >= 3 {
            guard let memberID = self.memberID else {
                throw KafkaError.missingValue
            }
            buffer.write(memberID, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 3 {
            buffer.write(groupInstanceID, lengthEncoding: lengthEncoding)
        }
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 3 {
            buffer.write(taggedFields)
        }
    }
}
