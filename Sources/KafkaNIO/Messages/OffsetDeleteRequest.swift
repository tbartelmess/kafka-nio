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


struct OffsetDeleteRequest: KafkaRequest { 
    init(apiVersion: APIVersion, name: String, partitions: [OffsetDeleteRequestPartition]) {
        self.apiVersion = apiVersion
        self.name = name
        self.partitions = partitions
    }
    let apiKey: APIKey = .offsetDelete
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The unique group identifier.
    let groupID: String
    
    /// The topics to delete offsets for
    let topics: [OffsetDeleteRequestTopic]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(groupID, lengthEncoding: lengthEncoding)
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }
}
