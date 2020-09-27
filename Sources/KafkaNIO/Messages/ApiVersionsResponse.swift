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


struct ApiVersionsResponse: KafkaResponse { 
    init(apiVersion: APIVersion, apiKey: APIKey, minVersion: Int16, maxVersion: Int16) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.apiKey = apiKey
        self.minVersion = minVersion
        self.maxVersion = maxVersion
    }
    
    init(apiVersion: APIVersion, name: String?, minVersion: Int16?, maxVersion: Int16?) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.name = name
        self.minVersion = minVersion
        self.maxVersion = maxVersion
    }
    
    init(apiVersion: APIVersion, name: String?, maxVersionLevel: Int16?, minVersionLevel: Int16?) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.name = name
        self.maxVersionLevel = maxVersionLevel
        self.minVersionLevel = minVersionLevel
    }
    let apiKey: APIKey = .apiVersions
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The top-level error code.
    let errorCode: ErrorCode
    
    /// The APIs supported by the broker.
    let apiKeys: [ApiVersionsResponseKey]
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 3) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        errorCode = try buffer.read()
        apiKeys = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 1 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
        if apiVersion >= 3 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, errorCode: ErrorCode, apiKeys: [ApiVersionsResponseKey], throttleTimeMs: Int32?, supportedFeatures: [SupportedFeatureKey]?, finalizedFeaturesEpoch: Int32?, finalizedFeatures: [FinalizedFeatureKey]?) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.errorCode = errorCode
        self.apiKeys = apiKeys
        self.throttleTimeMs = throttleTimeMs
    }
}