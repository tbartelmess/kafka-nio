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


struct ListPartitionReassignmentsRequest: KafkaRequest { 
    init(apiVersion: APIVersion, name: String, partitionIndexes: [Int32]) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.name = name
        self.partitionIndexes = partitionIndexes
    }
    let apiKey: APIKey = .listPartitionReassignments
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The time in ms to wait for the request to complete.
    let timeoutMs: Int32
    
    /// The topics to list partition reassignments for, or null to list everything.
    let topics: [ListPartitionReassignmentsTopics]?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 0) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(timeoutMs)
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 0 {
            buffer.write(taggedFields)
        }
    }
}
