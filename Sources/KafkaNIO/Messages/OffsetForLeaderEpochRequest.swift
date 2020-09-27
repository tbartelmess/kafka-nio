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


struct OffsetForLeaderEpochRequest: KafkaRequest { 
    init(apiVersion: APIVersion, name: String, partitions: [OffsetForLeaderPartition]) {
        self.apiVersion = apiVersion
        self.name = name
        self.partitions = partitions
    }
    let apiKey: APIKey = .offsetForLeaderEpoch
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The broker ID of the follower, of -1 if this request is from a consumer.
    let replicaID: Int32?
    
    /// Each topic to get offsets for.
    let topics: [OffsetForLeaderTopic]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        if apiVersion >= 3 {
            guard let replicaID = self.replicaID else {
                throw KafkaError.missingValue
            }
            buffer.write(replicaID)
        }
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }
}
