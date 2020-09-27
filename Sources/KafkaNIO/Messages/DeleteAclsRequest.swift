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
    init(apiVersion: APIVersion, resourceTypeFilter: Int8, resourceNameFilter: String?, patternTypeFilter: Int8?, principalFilter: String?, hostFilter: String?, operation: Int8, permissionType: Int8) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.resourceTypeFilter = resourceTypeFilter
        self.resourceNameFilter = resourceNameFilter
        self.patternTypeFilter = patternTypeFilter
        self.principalFilter = principalFilter
        self.hostFilter = hostFilter
        self.operation = operation
        self.permissionType = permissionType
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
