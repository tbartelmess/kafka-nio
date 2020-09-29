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


struct ListOffsetResponse: KafkaResponse { 
    struct ListOffsetTopicResponse: KafkaResponseStruct {
        struct ListOffsetPartitionResponse: KafkaResponseStruct {
        
            
            /// The partition index.
            let partitionIndex: Int32    
            /// The partition error code, or 0 if there was no error.
            let errorCode: ErrorCode    
            /// The result offsets.
            let oldStyleOffsets: [Int64]?    
            /// The timestamp associated with the returned offset.
            let timestamp: Int64?    
            /// The returned offset.
            let offset: Int64?    
            /// None
            let leaderEpoch: Int32?
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = .bigEndian
                partitionIndex = try buffer.read()
                errorCode = try buffer.read()
                if apiVersion <= 0 {
                    oldStyleOffsets = try buffer.read(lengthEncoding: lengthEncoding)
                } else { 
                    oldStyleOffsets = nil
                }
                if apiVersion >= 1 {
                    timestamp = try buffer.read()
                } else { 
                    timestamp = nil
                }
                if apiVersion >= 1 {
                    offset = try buffer.read()
                } else { 
                    offset = nil
                }
                if apiVersion >= 4 {
                    leaderEpoch = try buffer.read()
                } else { 
                    leaderEpoch = nil
                }
            }
            init(partitionIndex: Int32, errorCode: ErrorCode, oldStyleOffsets: [Int64]?, timestamp: Int64?, offset: Int64?, leaderEpoch: Int32?) {
                self.partitionIndex = partitionIndex
                self.errorCode = errorCode
                self.oldStyleOffsets = oldStyleOffsets
                self.timestamp = timestamp
                self.offset = offset
                self.leaderEpoch = leaderEpoch
            }
        
        }
    
        
        /// The topic name
        let name: String    
        /// Each partition in the response.
        let partitions: [ListOffsetPartitionResponse]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            name = try buffer.read(lengthEncoding: lengthEncoding)
            partitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        init(name: String, partitions: [ListOffsetPartitionResponse]) {
            self.name = name
            self.partitions = partitions
        }
    
    }
    
    let apiKey: APIKey = .listOffset
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// Each topic in the response.
    let topics: [ListOffsetTopicResponse]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        if apiVersion >= 2 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
        topics = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32?, topics: [ListOffsetTopicResponse]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.throttleTimeMs = throttleTimeMs
        self.topics = topics
    }
}