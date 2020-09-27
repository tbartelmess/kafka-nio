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


struct ElectLeadersRequest: KafkaRequest { 
    init(apiVersion: APIVersion, topic: String, partitionID: [Int32]) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.topic = topic
        self.partitionID = partitionID
    }
    let apiKey: APIKey = .electLeaders
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// Type of elections to conduct for the partition. A value of '0' elects the preferred replica. A value of '1' elects the first live replica if there are no in-sync replica.
    let electionType: Int8?
    
    /// The topic partitions to elect leaders.
    let topicPartitions: [TopicPartitions]?
    
    /// The time in ms to wait for the election to complete.
    let timeoutMs: Int32


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        if apiVersion >= 1 {
            guard let electionType = self.electionType else {
                throw KafkaError.missingValue
            }
            buffer.write(electionType)
        }
        try buffer.write(topicPartitions, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        buffer.write(timeoutMs)
        if apiVersion >= 2 {
            buffer.write(taggedFields)
        }
    }
}
