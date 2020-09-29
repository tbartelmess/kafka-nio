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


struct OffsetDeleteResponse: KafkaResponse { 
    struct OffsetDeleteResponseTopic: KafkaResponseStruct {
        struct OffsetDeleteResponsePartition: KafkaResponseStruct {
        
            
            /// The partition index.
            let partitionIndex: Int32    
            /// The error code, or 0 if there was no error.
            let errorCode: ErrorCode
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                partitionIndex = try buffer.read()
                errorCode = try buffer.read()
            }
            init(partitionIndex: Int32, errorCode: ErrorCode) {
                self.partitionIndex = partitionIndex
                self.errorCode = errorCode
            }
        
        }
    
        
        /// The topic name.
        let name: String    
        /// The responses for each partition in the topic.
        let partitions: [OffsetDeleteResponsePartition]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            name = try buffer.read(lengthEncoding: lengthEncoding)
            partitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        init(name: String, partitions: [OffsetDeleteResponsePartition]) {
            self.name = name
            self.partitions = partitions
        }
    
    }
    
    let apiKey: APIKey = .offsetDelete
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The top-level error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The responses for each topic.
    let topics: [OffsetDeleteResponseTopic]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        errorCode = try buffer.read()
        throttleTimeMs = try buffer.read()
        topics = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, errorCode: ErrorCode, throttleTimeMs: Int32, topics: [OffsetDeleteResponseTopic]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.errorCode = errorCode
        self.throttleTimeMs = throttleTimeMs
        self.topics = topics
    }
}