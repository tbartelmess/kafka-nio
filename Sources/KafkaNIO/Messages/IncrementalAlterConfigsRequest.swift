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


struct IncrementalAlterConfigsRequest: KafkaRequest { 
    init(apiVersion: APIVersion, resourceType: Int8, resourceName: String, configs: [AlterableConfig]) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.resourceType = resourceType
        self.resourceName = resourceName
        self.configs = configs
    }
    let apiKey: APIKey = .incrementalAlterConfigs
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The incremental updates for each resource.
    let resources: [AlterConfigsResource]
    
    /// True if we should validate the request, but not change the configurations.
    let validateOnly: Bool


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 1) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(resources, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        buffer.write(validateOnly)
        if apiVersion >= 1 {
            buffer.write(taggedFields)
        }
    }
}
