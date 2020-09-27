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


struct OffsetForLeaderEpochResponse: KafkaResponse { 
    struct OffsetForLeaderTopicResult: KafkaResponseStruct {
        struct OffsetForLeaderPartitionResult: KafkaResponseStruct {
        
            
            /// The error code 0, or if there was no error.
            let errorCode: ErrorCode    
            /// The partition index.
            let partitionIndex: Int32    
            /// The leader epoch of the partition.
            let leaderEpoch: Int32?    
            /// The end offset of the epoch.
            let endOffset: Int64
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                errorCode = try buffer.read()
                partitionIndex = try buffer.read()
                if apiVersion >= 1 {
                    leaderEpoch = try buffer.read()
                } else { 
                    leaderEpoch = nil
                }
                endOffset = try buffer.read()
            }
            init(errorCode: ErrorCode, partitionIndex: Int32, leaderEpoch: Int32?, endOffset: Int64) {
                self.errorCode = errorCode
                self.partitionIndex = partitionIndex
                self.leaderEpoch = leaderEpoch
                self.endOffset = endOffset
            }
        
        }
    
        
        /// The topic name.
        let name: String    
        /// Each partition in the topic we fetched offsets for.
        let partitions: [OffsetForLeaderPartitionResult]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            name = try buffer.read(lengthEncoding: lengthEncoding)
            partitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        init(name: String, partitions: [OffsetForLeaderPartitionResult]) {
            self.name = name
            self.partitions = partitions
        }
    
    }
    
    let apiKey: APIKey = .offsetForLeaderEpoch
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// Each topic we fetched offsets for.
    let topics: [OffsetForLeaderTopicResult]


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


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32?, topics: [OffsetForLeaderTopicResult]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.throttleTimeMs = throttleTimeMs
        self.topics = topics
    }
}