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


struct ListPartitionReassignmentsResponse: KafkaResponse { 
    struct OngoingTopicReassignment: KafkaResponseStruct {
        struct OngoingPartitionReassignment: KafkaResponseStruct {
        
            
            /// The index of the partition.
            let partitionIndex: Int32    
            /// The current replica set.
            let replicas: [Int32]    
            /// The set of replicas we are currently adding.
            let addingReplicas: [Int32]    
            /// The set of replicas we are currently removing.
            let removingReplicas: [Int32]
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 0) ? .varint : .bigEndian
                partitionIndex = try buffer.read()
                replicas = try buffer.read(lengthEncoding: lengthEncoding)
                addingReplicas = try buffer.read(lengthEncoding: lengthEncoding)
                removingReplicas = try buffer.read(lengthEncoding: lengthEncoding)
                if apiVersion >= 0 {
                    let _ : [TaggedField] = try buffer.read()
                }
            }
            init(partitionIndex: Int32, replicas: [Int32], addingReplicas: [Int32], removingReplicas: [Int32]) {
                self.partitionIndex = partitionIndex
                self.replicas = replicas
                self.addingReplicas = addingReplicas
                self.removingReplicas = removingReplicas
            }
        
        }
    
        
        /// The topic name.
        let name: String    
        /// The ongoing reassignments for each partition.
        let partitions: [OngoingPartitionReassignment]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 0) ? .varint : .bigEndian
            name = try buffer.read(lengthEncoding: lengthEncoding)
            partitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 0 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(name: String, partitions: [OngoingPartitionReassignment]) {
            self.name = name
            self.partitions = partitions
        }
    
    }
    
    let apiKey: APIKey = .listPartitionReassignments
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The top-level error code, or 0 if there was no error
    let errorCode: ErrorCode
    
    /// The top-level error message, or null if there was no error.
    let errorMessage: String?
    
    /// The ongoing reassignments for each topic.
    let topics: [OngoingTopicReassignment]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 0) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        errorCode = try buffer.read()
        errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
        topics = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 0 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32, errorCode: ErrorCode, errorMessage: String?, topics: [OngoingTopicReassignment]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.topics = topics
    }
}