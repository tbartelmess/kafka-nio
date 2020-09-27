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


struct MetadataRequest: KafkaRequest { 
    init(apiVersion: APIVersion, name: String) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.name = name
    }
    let apiKey: APIKey = .metadata
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The topics to fetch metadata for.
    let topics: [MetadataRequestTopic]?
    
    /// If this is true, the broker may auto-create topics that we requested which do not already exist, if it is configured to do so.
    let allowAutoTopicCreation: Bool?
    
    /// Whether to include cluster authorized operations.
    let includeClusterAuthorizedOperations: Bool?
    
    /// Whether to include topic authorized operations.
    let includeTopicAuthorizedOperations: Bool?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 9) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 4 {
            guard let allowAutoTopicCreation = self.allowAutoTopicCreation else {
                throw KafkaError.missingValue
            }
            buffer.write(allowAutoTopicCreation)
        }
        if apiVersion >= 8 {
            guard let includeClusterAuthorizedOperations = self.includeClusterAuthorizedOperations else {
                throw KafkaError.missingValue
            }
            buffer.write(includeClusterAuthorizedOperations)
        }
        if apiVersion >= 8 {
            guard let includeTopicAuthorizedOperations = self.includeTopicAuthorizedOperations else {
                throw KafkaError.missingValue
            }
            buffer.write(includeTopicAuthorizedOperations)
        }
        if apiVersion >= 9 {
            buffer.write(taggedFields)
        }
    }
}
