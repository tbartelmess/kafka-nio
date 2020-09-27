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
    init(apiVersion: APIVersion, resourceType: Int8, resourceName: String, resourcePatternType: Int8?, principal: String, host: String, operation: Int8, permissionType: Int8) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.resourceType = resourceType
        self.resourceName = resourceName
        self.resourcePatternType = resourcePatternType
        self.principal = principal
        self.host = host
        self.operation = operation
        self.permissionType = permissionType
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
