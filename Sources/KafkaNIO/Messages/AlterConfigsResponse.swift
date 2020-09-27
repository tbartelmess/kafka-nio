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


struct AlterConfigsResponse: KafkaResponse { 
    init(apiVersion: APIVersion, errorCode: ErrorCode, errorMessage: String?, resourceType: Int8, resourceName: String) {
        self.apiVersion = apiVersion
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.resourceType = resourceType
        self.resourceName = resourceName
    }
    let apiKey: APIKey = .alterConfigs
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// Duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The responses for each resource.
    let responses: [AlterConfigsResourceResponse]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        responses = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32, responses: [AlterConfigsResourceResponse]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.throttleTimeMs = throttleTimeMs
        self.responses = responses
    }
}