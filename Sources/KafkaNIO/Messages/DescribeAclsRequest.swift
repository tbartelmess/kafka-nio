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


struct DescribeAclsRequest: KafkaRequest { 
    
    let apiKey: APIKey = .describeAcls
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The resource type.
    let resourceTypeFilter: Int8
    
    /// The resource name, or null to match any resource name.
    let resourceNameFilter: String?
    
    /// The resource pattern to match.
    let patternTypeFilter: Int8?
    
    /// The principal to match, or null to match any principal.
    let principalFilter: String?
    
    /// The host to match, or null to match any host.
    let hostFilter: String?
    
    /// The operation to match.
    let operation: Int8
    
    /// The permission type to match.
    let permissionType: Int8


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
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
