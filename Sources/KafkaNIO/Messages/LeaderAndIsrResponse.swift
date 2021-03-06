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


struct LeaderAndIsrResponse: KafkaResponse { 
    struct LeaderAndIsrPartitionError: KafkaResponseStruct {
    
        
        /// The topic name.
        let topicName: String    
        /// The partition index.
        let partitionIndex: Int32    
        /// The partition error code, or 0 if there was no error.
        let errorCode: ErrorCode
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 4) ? .varint : .bigEndian
            topicName = try buffer.read(lengthEncoding: lengthEncoding)
            partitionIndex = try buffer.read()
            errorCode = try buffer.read()
            if apiVersion >= 4 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(topicName: String, partitionIndex: Int32, errorCode: ErrorCode) {
            self.topicName = topicName
            self.partitionIndex = partitionIndex
            self.errorCode = errorCode
        }
    
    }
    
    let apiKey: APIKey = .leaderAndIsr
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// Each partition.
    let partitionErrors: [LeaderAndIsrPartitionError]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 4) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        errorCode = try buffer.read()
        partitionErrors = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 4 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, errorCode: ErrorCode, partitionErrors: [LeaderAndIsrPartitionError]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.errorCode = errorCode
        self.partitionErrors = partitionErrors
    }
}