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


struct OffsetFetchRequest: KafkaRequest { 
    init(apiVersion: APIVersion, name: String, partitionIndexes: [Int32]) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.name = name
        self.partitionIndexes = partitionIndexes
    }
    let apiKey: APIKey = .offsetFetch
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The group to fetch offsets for.
    let groupID: String
    
    /// Each topic we would like to fetch offsets for, or null to fetch offsets for all topics.
    let topics: [OffsetFetchRequestTopic]?
    
    /// Whether broker should hold on returning unstable offsets but set a retriable error code for the partition.
    let requireStable: Bool?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 6) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(groupID, lengthEncoding: lengthEncoding)
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 7 {
            guard let requireStable = self.requireStable else {
                throw KafkaError.missingValue
            }
            buffer.write(requireStable)
        }
        if apiVersion >= 6 {
            buffer.write(taggedFields)
        }
    }
}
