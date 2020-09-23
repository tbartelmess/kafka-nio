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


struct CreateTopicsRequest: KafkaRequest { 
    struct CreatableTopic: KafkaRequestStruct {
        struct CreatableReplicaAssignment: KafkaRequestStruct {
        
            
            /// The partition index.
            let partitionIndex: Int32    
            /// The brokers to place the partition on.
            let brokerIDs: [Int32]
            let taggedFields: [TaggedField] = []
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 5) ? .varint : .bigEndian
                buffer.write(partitionIndex)
                buffer.write(brokerIDs, lengthEncoding: lengthEncoding)
                if apiVersion >= 5 {
                    buffer.write(taggedFields)
                }
            
            }
        }
        struct CreateableTopicConfig: KafkaRequestStruct {
        
            
            /// The configuration name.
            let name: String    
            /// The configuration value.
            let value: String?
            let taggedFields: [TaggedField] = []
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 5) ? .varint : .bigEndian
                buffer.write(name, lengthEncoding: lengthEncoding)
                buffer.write(value, lengthEncoding: lengthEncoding)
                if apiVersion >= 5 {
                    buffer.write(taggedFields)
                }
            
            }
        }
    
        
        /// The topic name.
        let name: String    
        /// The number of partitions to create in the topic, or -1 if we are either specifying a manual partition assignment or using the default partitions.
        let numPartitions: Int32    
        /// The number of replicas to create for each partition in the topic, or -1 if we are either specifying a manual partition assignment or using the default replication factor.
        let replicationFactor: Int16    
        /// The manual partition assignment, or the empty array if we are using automatic assignment.
        let assignments: [CreatableReplicaAssignment]    
        /// The custom topic configurations to set.
        let configs: [CreateableTopicConfig]
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 5) ? .varint : .bigEndian
            buffer.write(name, lengthEncoding: lengthEncoding)
            buffer.write(numPartitions)
            buffer.write(replicationFactor)
            try buffer.write(assignments, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            try buffer.write(configs, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 5 {
                buffer.write(taggedFields)
            }
        
        }
    }
    let apiKey: APIKey = .createTopics
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The topics to create.
    let topics: [CreatableTopic]
    
    /// How long to wait in milliseconds before timing out the request.
    let timeoutMs: Int32
    
    /// If true, check that the topics can be created as specified, but don't create anything.
    let validateOnly: Bool?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 5) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        buffer.write(timeoutMs)
        if apiVersion >= 1 {
            guard let validateOnly = self.validateOnly else {
                throw KafkaError.missingValue
            }
            buffer.write(validateOnly)
        }
        if apiVersion >= 5 {
            buffer.write(taggedFields)
        }
    }
}
