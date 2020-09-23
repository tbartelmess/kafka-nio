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


struct DeleteAclsResponse: KafkaResponse { 
    struct DeleteAclsFilterResult: KafkaResponseStruct {
        struct DeleteAclsMatchingAcl: KafkaResponseStruct {
        
            
            /// The deletion error code, or 0 if the deletion succeeded.
            let errorCode: ErrorCode    
            /// The deletion error message, or null if the deletion succeeded.
            let errorMessage: String?    
            /// The ACL resource type.
            let resourceType: Int8    
            /// The ACL resource name.
            let resourceName: String    
            /// The ACL resource pattern type.
            let patternType: Int8?    
            /// The ACL principal.
            let principal: String    
            /// The ACL host.
            let host: String    
            /// The ACL operation.
            let operation: Int8    
            /// The ACL permission type.
            let permissionType: Int8
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
                errorCode = try buffer.read()
                errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
                resourceType = try buffer.read()
                resourceName = try buffer.read(lengthEncoding: lengthEncoding)
                if apiVersion >= 1 {
                    patternType = try buffer.read()
                } else { 
                    patternType = nil
                }
                principal = try buffer.read(lengthEncoding: lengthEncoding)
                host = try buffer.read(lengthEncoding: lengthEncoding)
                operation = try buffer.read()
                permissionType = try buffer.read()
                if apiVersion >= 2 {
                    let _ : [TaggedField] = try buffer.read()
                }
            }
        
        }
    
        
        /// The error code, or 0 if the filter succeeded.
        let errorCode: ErrorCode    
        /// The error message, or null if the filter succeeded.
        let errorMessage: String?    
        /// The ACLs which matched this filter.
        let matchingAcls: [DeleteAclsMatchingAcl]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            errorCode = try buffer.read()
            errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
            matchingAcls = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 2 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
    
    }
    let apiKey: APIKey = .deleteAcls
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The results for each filter.
    let filterResults: [DeleteAclsFilterResult]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        filterResults = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 2 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }
}