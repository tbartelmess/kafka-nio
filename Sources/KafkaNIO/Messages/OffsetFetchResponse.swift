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


struct OffsetFetchResponse: KafkaResponse { 
    struct OffsetFetchResponseTopic: KafkaResponseStruct {
        struct OffsetFetchResponsePartition: KafkaResponseStruct {
        
            
            /// The partition index.
            let partitionIndex: Int32    
            /// The committed message offset.
            let committedOffset: Int64    
            /// The leader epoch.
            let committedLeaderEpoch: Int32?    
            /// The partition metadata.
            let metadata: String?    
            /// The error code, or 0 if there was no error.
            let errorCode: ErrorCode
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 6) ? .varint : .bigEndian
                partitionIndex = try buffer.read()
                committedOffset = try buffer.read()
                if apiVersion >= 5 {
                    committedLeaderEpoch = try buffer.read()
                } else { 
                    committedLeaderEpoch = nil
                }
                metadata = try buffer.read(lengthEncoding: lengthEncoding)
                errorCode = try buffer.read()
                if apiVersion >= 6 {
                    let _ : [TaggedField] = try buffer.read()
                }
            }
            init(partitionIndex: Int32, committedOffset: Int64, committedLeaderEpoch: Int32?, metadata: String?, errorCode: ErrorCode) {
                self.partitionIndex = partitionIndex
                self.committedOffset = committedOffset
                self.committedLeaderEpoch = committedLeaderEpoch
                self.metadata = metadata
                self.errorCode = errorCode
            }
        
        }
    
        
        /// The topic name.
        let name: String    
        /// The responses per partition
        let partitions: [OffsetFetchResponsePartition]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 6) ? .varint : .bigEndian
            name = try buffer.read(lengthEncoding: lengthEncoding)
            partitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 6 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(name: String, partitions: [OffsetFetchResponsePartition]) {
            self.name = name
            self.partitions = partitions
        }
    
    }
    
    let apiKey: APIKey = .offsetFetch
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// The responses per topic.
    let topics: [OffsetFetchResponseTopic]
    
    /// The top-level error code, or 0 if there was no error.
    let errorCode: ErrorCode?
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 6) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        if apiVersion >= 3 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
        topics = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 2 {
            errorCode = try buffer.read()
        } else { 
            errorCode = nil
        }
        if apiVersion >= 6 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32?, topics: [OffsetFetchResponseTopic], errorCode: ErrorCode?) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.topics = topics
        self.errorCode = errorCode
    }
}