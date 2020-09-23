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


struct CreateAclsRequest: KafkaRequest { 
    struct AclCreation: KafkaRequestStruct {
    
        
        /// The type of the resource.
        let resourceType: Int8    
        /// The resource name for the ACL.
        let resourceName: String    
        /// The pattern type for the ACL.
        let resourcePatternType: Int8?    
        /// The principal for the ACL.
        let principal: String    
        /// The host for the ACL.
        let host: String    
        /// The operation type for the ACL (read, write, etc.).
        let operation: Int8    
        /// The permission type for the ACL (allow, deny, etc.).
        let permissionType: Int8
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            buffer.write(resourceType)
            buffer.write(resourceName, lengthEncoding: lengthEncoding)
            if apiVersion >= 1 {
                guard let resourcePatternType = self.resourcePatternType else {
                    throw KafkaError.missingValue
                }
                buffer.write(resourcePatternType)
            }
            buffer.write(principal, lengthEncoding: lengthEncoding)
            buffer.write(host, lengthEncoding: lengthEncoding)
            buffer.write(operation)
            buffer.write(permissionType)
            if apiVersion >= 2 {
                buffer.write(taggedFields)
            }
        
        }
    }
    let apiKey: APIKey = .createAcls
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The ACLs that we want to create.
    let creations: [AclCreation]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(creations, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 2 {
            buffer.write(taggedFields)
        }
    }
}
