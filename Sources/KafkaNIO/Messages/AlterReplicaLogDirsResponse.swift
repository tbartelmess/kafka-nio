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


struct AlterReplicaLogDirsResponse: KafkaResponse { 
    struct AlterReplicaLogDirTopicResult: KafkaResponseStruct {
        struct AlterReplicaLogDirPartitionResult: KafkaResponseStruct {
        
            
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
    
        
        /// The name of the topic.
        let topicName: String    
        /// The results for each partition.
        let partitions: [AlterReplicaLogDirPartitionResult]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            topicName = try buffer.read(lengthEncoding: lengthEncoding)
            partitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        init(topicName: String, partitions: [AlterReplicaLogDirPartitionResult]) {
            self.topicName = topicName
            self.partitions = partitions
        }
    
    }
    
    let apiKey: APIKey = .alterReplicaLogDirs
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// Duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The results for each topic.
    let results: [AlterReplicaLogDirTopicResult]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        results = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32, results: [AlterReplicaLogDirTopicResult]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.throttleTimeMs = throttleTimeMs
        self.results = results
    }
}