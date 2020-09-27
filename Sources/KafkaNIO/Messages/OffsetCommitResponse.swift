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


struct OffsetCommitResponse: KafkaResponse { 
    struct OffsetCommitResponseTopic: KafkaResponseStruct {
        struct OffsetCommitResponsePartition: KafkaResponseStruct {
        
            
            /// The partition index.
            let partitionIndex: Int32    
            /// The error code, or 0 if there was no error.
            let errorCode: ErrorCode
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                partitionIndex = try buffer.read()
                errorCode = try buffer.read()
                if apiVersion >= 8 {
                    let _ : [TaggedField] = try buffer.read()
                }
            }
            init(partitionIndex: Int32, errorCode: ErrorCode) {
                self.partitionIndex = partitionIndex
                self.errorCode = errorCode
            }
        
        }
    
        
        /// The topic name.
        let name: String    
        /// The responses for each partition in the topic.
        let partitions: [OffsetCommitResponsePartition]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 8) ? .varint : .bigEndian
            name = try buffer.read(lengthEncoding: lengthEncoding)
            partitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 8 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(name: String, partitions: [OffsetCommitResponsePartition]) {
            self.name = name
            self.partitions = partitions
        }
    
    }
    
    let apiKey: APIKey = .offsetCommit
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// The responses for each topic.
    let topics: [OffsetCommitResponseTopic]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 8) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        if apiVersion >= 3 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
        topics = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 8 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32?, topics: [OffsetCommitResponseTopic]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.topics = topics
    }
}