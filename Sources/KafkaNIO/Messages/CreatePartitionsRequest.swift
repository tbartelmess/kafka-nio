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


struct CreatePartitionsRequest: KafkaRequest { 
    init(apiVersion: APIVersion, name: String, count: Int32, assignments: [CreatePartitionsAssignment]?) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.name = name
        self.count = count
        self.assignments = assignments
    }
    let apiKey: APIKey = .createPartitions
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// Each topic that we want to create new partitions inside.
    let topics: [CreatePartitionsTopic]
    
    /// The time in ms to wait for the partitions to be created.
    let timeoutMs: Int32
    
    /// If true, then validate the request, but don't actually increase the number of partitions.
    let validateOnly: Bool


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        buffer.write(timeoutMs)
        buffer.write(validateOnly)
        if apiVersion >= 2 {
            buffer.write(taggedFields)
        }
    }
}
