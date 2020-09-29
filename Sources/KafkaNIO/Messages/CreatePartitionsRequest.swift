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


struct CreatePartitionsRequest: KafkaRequest { 
    struct CreatePartitionsTopic: KafkaRequestStruct {
        struct CreatePartitionsAssignment: KafkaRequestStruct {
        
            
            /// The assigned broker IDs.
            let brokerIDs: [Int32]
            let taggedFields: [TaggedField] = []
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
                buffer.write(brokerIDs, lengthEncoding: lengthEncoding)
                if apiVersion >= 2 {
                    buffer.write(taggedFields)
                }
            }
        
            init(brokerIDs: [Int32]) {
                self.brokerIDs = brokerIDs
            }
        
        }
    
        
        /// The topic name.
        let name: String    
        /// The new partition count.
        let count: Int32    
        /// The new partition assignments.
        let assignments: [CreatePartitionsAssignment]?
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            buffer.write(name, lengthEncoding: lengthEncoding)
            buffer.write(count)
            try buffer.write(assignments, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 2 {
                buffer.write(taggedFields)
            }
        }
    
        init(name: String, count: Int32, assignments: [CreatePartitionsAssignment]?) {
            self.name = name
            self.count = count
            self.assignments = assignments
        }
    
    }
    
    let apiKey: APIKey = .createPartitions
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// Each topic that we want to create new partitions inside.
    let topics: [CreatePartitionsTopic]
    
    /// The time in ms to wait for the partitions to be created.
    let timeoutMs: Int32
    
    /// If true, then validate the request, but don't actually increase the number of partitions.
    let validateOnly: Bool


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        buffer.write(timeoutMs)
        buffer.write(validateOnly)
        if apiVersion >= 2 {
            buffer.write(taggedFields)
        }
    }
}
