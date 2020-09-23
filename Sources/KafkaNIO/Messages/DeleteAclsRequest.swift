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


struct DeleteAclsRequest: KafkaRequest { 
    struct DeleteAclsFilter: KafkaRequestStruct {
    
        
        /// The resource type.
        let resourceTypeFilter: Int8    
        /// The resource name.
        let resourceNameFilter: String?    
        /// The pattern type.
        let patternTypeFilter: Int8?    
        /// The principal filter, or null to accept all principals.
        let principalFilter: String?    
        /// The host filter, or null to accept all hosts.
        let hostFilter: String?    
        /// The ACL operation.
        let operation: Int8    
        /// The permission type.
        let permissionType: Int8
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            buffer.write(resourceTypeFilter)
            buffer.write(resourceNameFilter, lengthEncoding: lengthEncoding)
            if apiVersion >= 1 {
                guard let patternTypeFilter = self.patternTypeFilter else {
                    throw KafkaError.missingValue
                }
                buffer.write(patternTypeFilter)
            }
            buffer.write(principalFilter, lengthEncoding: lengthEncoding)
            buffer.write(hostFilter, lengthEncoding: lengthEncoding)
            buffer.write(operation)
            buffer.write(permissionType)
            if apiVersion >= 2 {
                buffer.write(taggedFields)
            }
        
        }
    }
    let apiKey: APIKey = .deleteAcls
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The filters to use when deleting ACLs.
    let filters: [DeleteAclsFilter]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(filters, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 2 {
            buffer.write(taggedFields)
        }
    }
}
