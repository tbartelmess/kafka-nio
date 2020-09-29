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


struct StopReplicaResponse: KafkaResponse { 
    struct StopReplicaPartitionError: KafkaResponseStruct {
    
        
        /// The topic name.
        let topicName: String    
        /// The partition index.
        let partitionIndex: Int32    
        /// The partition error code, or 0 if there was no partition error.
        let errorCode: ErrorCode
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            topicName = try buffer.read(lengthEncoding: lengthEncoding)
            partitionIndex = try buffer.read()
            errorCode = try buffer.read()
            if apiVersion >= 2 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(topicName: String, partitionIndex: Int32, errorCode: ErrorCode) {
            self.topicName = topicName
            self.partitionIndex = partitionIndex
            self.errorCode = errorCode
        }
    
    }
    
    let apiKey: APIKey = .stopReplica
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The top-level error code, or 0 if there was no top-level error.
    let errorCode: ErrorCode
    
    /// The responses for each partition.
    let partitionErrors: [StopReplicaPartitionError]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        errorCode = try buffer.read()
        partitionErrors = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 2 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, errorCode: ErrorCode, partitionErrors: [StopReplicaPartitionError]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.errorCode = errorCode
        self.partitionErrors = partitionErrors
    }
}