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


struct DescribeConfigsRequest: KafkaRequest { 
    init(apiVersion: APIVersion, resourceType: Int8, resourceName: String, configurationKeys: [String]?) {
        self.apiVersion = apiVersion
        self.resourceType = resourceType
        self.resourceName = resourceName
        self.configurationKeys = configurationKeys
    }
    let apiKey: APIKey = .describeConfigs
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The resources whose configurations we want to describe.
    let resources: [DescribeConfigsResource]
    
    /// True if we should include all synonyms.
    let includeSynonyms: Bool?
    
    /// True if we should include configuration documentation.
    let includeDocumentation: Bool?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(resources, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 1 {
            guard let includeSynonyms = self.includeSynonyms else {
                throw KafkaError.missingValue
            }
            buffer.write(includeSynonyms)
        }
        if apiVersion >= 3 {
            guard let includeDocumentation = self.includeDocumentation else {
                throw KafkaError.missingValue
            }
            buffer.write(includeDocumentation)
        }
    }
}
