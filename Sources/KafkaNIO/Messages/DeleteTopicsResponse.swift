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


struct DeleteTopicsResponse: KafkaResponse { 
    struct DeletableTopicResult: KafkaResponseStruct {
    
        
        /// The topic name
        let name: String    
        /// The deletion error, or 0 if the deletion succeeded.
        let errorCode: ErrorCode    
        /// The error message, or null if there was no error.
        let errorMessage: String?
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 4) ? .varint : .bigEndian
            name = try buffer.read(lengthEncoding: lengthEncoding)
            errorCode = try buffer.read()
            if apiVersion >= 5 {
                errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
            } else { 
                errorMessage = nil
            }
            if apiVersion >= 4 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(name: String, errorCode: ErrorCode, errorMessage: String?) {
            self.name = name
            self.errorCode = errorCode
            self.errorMessage = errorMessage
        }
    
    }
    
    let apiKey: APIKey = .deleteTopics
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// The results for each topic we tried to delete.
    let responses: [DeletableTopicResult]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 4) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        if apiVersion >= 1 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
        responses = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 4 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32?, responses: [DeletableTopicResult]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.responses = responses
    }
}