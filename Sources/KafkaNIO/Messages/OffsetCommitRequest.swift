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


struct OffsetCommitRequest: KafkaRequest { 
    init(apiVersion: APIVersion, name: String, partitions: [OffsetCommitRequestPartition]) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.name = name
        self.partitions = partitions
    }
    let apiKey: APIKey = .offsetCommit
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The unique group identifier.
    let groupID: String
    
    /// The generation of the group.
    let generationID: Int32?
    
    /// The member ID assigned by the group coordinator.
    let memberID: String?
    
    /// The unique identifier of the consumer instance provided by end user.
    let groupInstanceID: String?
    
    /// The time period in ms to retain the offset.
    let retentionTimeMs: Int64?
    
    /// The topics to commit offsets for.
    let topics: [OffsetCommitRequestTopic]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 8) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(groupID, lengthEncoding: lengthEncoding)
        if apiVersion >= 1 {
            guard let generationID = self.generationID else {
                throw KafkaError.missingValue
            }
            buffer.write(generationID)
        }
        if apiVersion >= 1 {
            guard let memberID = self.memberID else {
                throw KafkaError.missingValue
            }
            buffer.write(memberID, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 7 {
            buffer.write(groupInstanceID, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 2 && apiVersion <= 4 {
            guard let retentionTimeMs = self.retentionTimeMs else {
                throw KafkaError.missingValue
            }
            buffer.write(retentionTimeMs)
        }
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 8 {
            buffer.write(taggedFields)
        }
    }
}
