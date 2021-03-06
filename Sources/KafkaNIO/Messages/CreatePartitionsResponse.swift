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


struct CreatePartitionsResponse: KafkaResponse { 
    struct CreatePartitionsTopicResult: KafkaResponseStruct {
    
        
        /// The topic name.
        let name: String    
        /// The result error, or zero if there was no error.
        let errorCode: ErrorCode    
        /// The result message, or null if there was no error.
        let errorMessage: String?
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            name = try buffer.read(lengthEncoding: lengthEncoding)
            errorCode = try buffer.read()
            errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
            if apiVersion >= 2 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(name: String, errorCode: ErrorCode, errorMessage: String?) {
            self.name = name
            self.errorCode = errorCode
            self.errorMessage = errorMessage
        }
    
    }
    
    let apiKey: APIKey = .createPartitions
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The partition creation results for each topic.
    let results: [CreatePartitionsTopicResult]
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


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32, results: [CreatePartitionsTopicResult]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.results = results
    }
}