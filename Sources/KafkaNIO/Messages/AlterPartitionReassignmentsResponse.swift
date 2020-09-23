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


struct AlterPartitionReassignmentsResponse: KafkaResponse { 
    struct ReassignableTopicResponse: KafkaResponseStruct {
        struct ReassignablePartitionResponse: KafkaResponseStruct {
        
            
            /// The partition index.
            let partitionIndex: Int32    
            /// The error code for this partition, or 0 if there was no error.
            let errorCode: ErrorCode    
            /// The error message for this partition, or null if there was no error.
            let errorMessage: String?
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 0) ? .varint : .bigEndian
                partitionIndex = try buffer.read()
                errorCode = try buffer.read()
                errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
                if apiVersion >= 0 {
                    let _ : [TaggedField] = try buffer.read()
                }
            }
        
        }
    
        
        /// The topic name
        let name: String    
        /// The responses to partitions to reassign
        let partitions: [ReassignablePartitionResponse]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 0) ? .varint : .bigEndian
            name = try buffer.read(lengthEncoding: lengthEncoding)
            partitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 0 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
    
    }
    let apiKey: APIKey = .alterPartitionReassignments
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The top-level error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// The top-level error message, or null if there was no error.
    let errorMessage: String?
    
    /// The responses to topics to reassign.
    let responses: [ReassignableTopicResponse]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 0) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        errorCode = try buffer.read()
        errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
        responses = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 0 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }
}