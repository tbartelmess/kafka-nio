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


struct AddPartitionsToTxnResponse: KafkaResponse { 
    struct AddPartitionsToTxnTopicResult: KafkaResponseStruct {
        struct AddPartitionsToTxnPartitionResult: KafkaResponseStruct {
        
            
            /// The partition indexes.
            let partitionIndex: Int32    
            /// The response error code.
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
        /// The results for each partition
        let results: [AddPartitionsToTxnPartitionResult]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            name = try buffer.read(lengthEncoding: lengthEncoding)
            results = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        init(name: String, results: [AddPartitionsToTxnPartitionResult]) {
            self.name = name
            self.results = results
        }
    
    }
    
    let apiKey: APIKey = .addPartitionsToTxn
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// Duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The results for each topic.
    let results: [AddPartitionsToTxnTopicResult]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        results = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32, results: [AddPartitionsToTxnTopicResult]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.throttleTimeMs = throttleTimeMs
        self.results = results
    }
}