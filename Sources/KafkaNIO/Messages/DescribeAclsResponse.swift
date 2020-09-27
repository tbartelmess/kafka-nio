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


struct DescribeAclsResponse: KafkaResponse { 
    struct DescribeAclsResource: KafkaResponseStruct {
        struct AclDescription: KafkaResponseStruct {
        
            
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
                principal = try buffer.read(lengthEncoding: lengthEncoding)
                host = try buffer.read(lengthEncoding: lengthEncoding)
                operation = try buffer.read()
                permissionType = try buffer.read()
                if apiVersion >= 2 {
                    let _ : [TaggedField] = try buffer.read()
                }
            }
            init(principal: String, host: String, operation: Int8, permissionType: Int8) {
                self.principal = principal
                self.host = host
                self.operation = operation
                self.permissionType = permissionType
            }
        
        }
    
        
        /// The resource type.
        let resourceType: Int8    
        /// The resource name.
        let resourceName: String    
        /// The resource pattern type.
        let patternType: Int8?    
        /// The ACLs.
        let acls: [AclDescription]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            resourceType = try buffer.read()
            resourceName = try buffer.read(lengthEncoding: lengthEncoding)
            if apiVersion >= 1 {
                patternType = try buffer.read()
            } else { 
                patternType = nil
            }
            acls = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 2 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(resourceType: Int8, resourceName: String, patternType: Int8?, acls: [AclDescription]) {
            self.resourceType = resourceType
            self.resourceName = resourceName
            self.patternType = patternType
            self.acls = acls
        }
    
    }
    
    let apiKey: APIKey = .describeAcls
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// The error message, or null if there was no error.
    let errorMessage: String?
    
    /// Each Resource that is referenced in an ACL.
    let resources: [DescribeAclsResource]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        errorCode = try buffer.read()
        errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
        resources = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 2 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32, errorCode: ErrorCode, errorMessage: String?, resources: [DescribeAclsResource]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.resources = resources
    }
}