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


struct DescribeLogDirsResponse: KafkaResponse { 
    struct DescribeLogDirsResult: KafkaResponseStruct {
        struct DescribeLogDirsTopic: KafkaResponseStruct {
            struct DescribeLogDirsPartition: KafkaResponseStruct {
            
                
                /// The partition index.
                let partitionIndex: Int32    
                /// The size of the log segments in this partition in bytes.
                let partitionSize: Int64    
                /// The lag of the log's LEO w.r.t. partition's HW (if it is the current log for the partition) or current replica's LEO (if it is the future log for the partition)
                let offsetLag: Int64    
                /// True if this log is created by AlterReplicaLogDirsRequest and will replace the current log of the replica in the future.
                let isFutureKey: Bool
                init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                    partitionIndex = try buffer.read()
                    partitionSize = try buffer.read()
                    offsetLag = try buffer.read()
                    isFutureKey = try buffer.read()
                    if apiVersion >= 2 {
                        let _ : [TaggedField] = try buffer.read()
                    }
                }
                init(partitionIndex: Int32, partitionSize: Int64, offsetLag: Int64, isFutureKey: Bool) {
                    self.partitionIndex = partitionIndex
                    self.partitionSize = partitionSize
                    self.offsetLag = offsetLag
                    self.isFutureKey = isFutureKey
                }
            
            }
        
            
            /// The topic name.
            let name: String    
            /// None
            let partitions: [DescribeLogDirsPartition]
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
                name = try buffer.read(lengthEncoding: lengthEncoding)
                partitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
                if apiVersion >= 2 {
                    let _ : [TaggedField] = try buffer.read()
                }
            }
            init(name: String, partitions: [DescribeLogDirsPartition]) {
                self.name = name
                self.partitions = partitions
            }
        
        }
    
        
        /// The error code, or 0 if there was no error.
        let errorCode: ErrorCode    
        /// The absolute log directory path.
        let logDir: String    
        /// Each topic.
        let topics: [DescribeLogDirsTopic]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            errorCode = try buffer.read()
            logDir = try buffer.read(lengthEncoding: lengthEncoding)
            topics = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 2 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(errorCode: ErrorCode, logDir: String, topics: [DescribeLogDirsTopic]) {
            self.errorCode = errorCode
            self.logDir = logDir
            self.topics = topics
        }
    
    }
    
    let apiKey: APIKey = .describeLogDirs
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The log directories.
    let results: [DescribeLogDirsResult]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        results = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 2 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32, results: [DescribeLogDirsResult]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.results = results
    }
}