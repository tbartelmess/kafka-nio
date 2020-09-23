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


struct AlterPartitionReassignmentsRequest: KafkaRequest { 
    struct ReassignableTopic: KafkaRequestStruct {
        struct ReassignablePartition: KafkaRequestStruct {
        
            
            /// The partition index.
            let partitionIndex: Int32    
            /// The replicas to place the partitions on, or null to cancel a pending reassignment for this partition.
            let replicas: [Int32]?
            let taggedFields: [TaggedField] = []
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 0) ? .varint : .bigEndian
                buffer.write(partitionIndex)
                buffer.write(replicas, lengthEncoding: lengthEncoding)
                if apiVersion >= 0 {
                    buffer.write(taggedFields)
                }
            
            }
        }
    
        
        /// The topic name.
        let name: String    
        /// The partitions to reassign.
        let partitions: [ReassignablePartition]
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 0) ? .varint : .bigEndian
            buffer.write(name, lengthEncoding: lengthEncoding)
            try buffer.write(partitions, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 0 {
                buffer.write(taggedFields)
            }
        
        }
    }
    let apiKey: APIKey = .alterPartitionReassignments
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The time in ms to wait for the request to complete.
    let timeoutMs: Int32
    
    /// The topics to reassign.
    let topics: [ReassignableTopic]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 0) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(timeoutMs)
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 0 {
            buffer.write(taggedFields)
        }
    }
}
