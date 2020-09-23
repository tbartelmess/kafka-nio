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


struct IncrementalAlterConfigsResponse: KafkaResponse { 
    struct AlterConfigsResourceResponse: KafkaResponseStruct {
    
        
        /// The resource error code.
        let errorCode: ErrorCode    
        /// The resource error message, or null if there was no error.
        let errorMessage: String?    
        /// The resource type.
        let resourceType: Int8    
        /// The resource name.
        let resourceName: String
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 1) ? .varint : .bigEndian
            errorCode = try buffer.read()
            errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
            resourceType = try buffer.read()
            resourceName = try buffer.read(lengthEncoding: lengthEncoding)
            if apiVersion >= 1 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
    
    }
    let apiKey: APIKey = .incrementalAlterConfigs
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// Duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The responses for each resource.
    let responses: [AlterConfigsResourceResponse]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 1) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        responses = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 1 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }
}