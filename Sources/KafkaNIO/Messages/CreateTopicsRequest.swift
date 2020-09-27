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


struct CreateTopicsRequest: KafkaRequest { 
    init(apiVersion: APIVersion, name: String, numPartitions: Int32, replicationFactor: Int16, assignments: [CreatableReplicaAssignment], configs: [CreateableTopicConfig]) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.name = name
        self.numPartitions = numPartitions
        self.replicationFactor = replicationFactor
        self.assignments = assignments
        self.configs = configs
    }
    let apiKey: APIKey = .createTopics
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The topics to create.
    let topics: [CreatableTopic]
    
    /// How long to wait in milliseconds before timing out the request.
    let timeoutMs: Int32
    
    /// If true, check that the topics can be created as specified, but don't create anything.
    let validateOnly: Bool?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 5) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        buffer.write(timeoutMs)
        if apiVersion >= 1 {
            guard let validateOnly = self.validateOnly else {
                throw KafkaError.missingValue
            }
            buffer.write(validateOnly)
        }
        if apiVersion >= 5 {
            buffer.write(taggedFields)
        }
    }
}
