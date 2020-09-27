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


struct DeleteRecordsResponse: KafkaResponse { 
    struct DeleteRecordsTopicResult: KafkaResponseStruct {
        struct DeleteRecordsPartitionResult: KafkaResponseStruct {
        
            
            /// The partition index.
            let partitionIndex: Int32    
            /// The partition low water mark.
            let lowWatermark: Int64    
            /// The deletion error code, or 0 if the deletion succeeded.
            let errorCode: ErrorCode
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                partitionIndex = try buffer.read()
                lowWatermark = try buffer.read()
                errorCode = try buffer.read()
                if apiVersion >= 2 {
                    let _ : [TaggedField] = try buffer.read()
                }
            }
            init(partitionIndex: Int32, lowWatermark: Int64, errorCode: ErrorCode) {
                self.partitionIndex = partitionIndex
                self.lowWatermark = lowWatermark
                self.errorCode = errorCode
            }
        
        }
    
        
        /// The topic name.
        let name: String    
        /// Each partition that we wanted to delete records from.
        let partitions: [DeleteRecordsPartitionResult]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            name = try buffer.read(lengthEncoding: lengthEncoding)
            partitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 2 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(name: String, partitions: [DeleteRecordsPartitionResult]) {
            self.name = name
            self.partitions = partitions
        }
    
    }
    
    let apiKey: APIKey = .deleteRecords
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// Each topic that we wanted to delete records from.
    let topics: [DeleteRecordsTopicResult]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        topics = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 2 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32, topics: [DeleteRecordsTopicResult]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.topics = topics
    }
}