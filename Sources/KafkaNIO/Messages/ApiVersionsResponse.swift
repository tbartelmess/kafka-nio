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
    struct ApiVersionsResponseKey: KafkaResponseStruct {
    
        
        /// The API index.
        let apiKey: APIKey    
        /// The minimum supported version, inclusive.
        let minVersion: Int16    
        /// The maximum supported version, inclusive.
        let maxVersion: Int16
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            apiKey = try buffer.read()
            minVersion = try buffer.read()
            maxVersion = try buffer.read()
            if apiVersion >= 3 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(apiKey: APIKey, minVersion: Int16, maxVersion: Int16) {
            self.apiKey = apiKey
            self.minVersion = minVersion
            self.maxVersion = maxVersion
        }
    
    }
    
    
    struct SupportedFeatureKey: KafkaResponseStruct {
    
        
        /// The name of the feature.
        let name: String?    
        /// The minimum supported version for the feature.
        let minVersion: Int16?    
        /// The maximum supported version for the feature.
        let maxVersion: Int16?
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 3) ? .varint : .bigEndian
            if apiVersion >= 3 {
                name = try buffer.read(lengthEncoding: lengthEncoding)
            } else { 
                name = nil
            }
            if apiVersion >= 3 {
                minVersion = try buffer.read()
            } else { 
                minVersion = nil
            }
            if apiVersion >= 3 {
                maxVersion = try buffer.read()
            } else { 
                maxVersion = nil
            }
            if apiVersion >= 3 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(name: String?, minVersion: Int16?, maxVersion: Int16?) {
            self.name = name
            self.minVersion = minVersion
            self.maxVersion = maxVersion
        }
    
    }
    
    
    struct FinalizedFeatureKey: KafkaResponseStruct {
    
        
        /// The name of the feature.
        let name: String?    
        /// The cluster-wide finalized max version level for the feature.
        let maxVersionLevel: Int16?    
        /// The cluster-wide finalized min version level for the feature.
        let minVersionLevel: Int16?
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 3) ? .varint : .bigEndian
            if apiVersion >= 3 {
                name = try buffer.read(lengthEncoding: lengthEncoding)
            } else { 
                name = nil
            }
            if apiVersion >= 3 {
                maxVersionLevel = try buffer.read()
            } else { 
                maxVersionLevel = nil
            }
            if apiVersion >= 3 {
                minVersionLevel = try buffer.read()
            } else { 
                minVersionLevel = nil
            }
            if apiVersion >= 3 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(name: String?, maxVersionLevel: Int16?, minVersionLevel: Int16?) {
            self.name = name
            self.maxVersionLevel = maxVersionLevel
            self.minVersionLevel = minVersionLevel
        }
    
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