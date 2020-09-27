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


struct DeleteRecordsRequest: KafkaRequest { 
    init(apiVersion: APIVersion, name: String, partitions: [DeleteRecordsPartition]) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.name = name
        self.partitions = partitions
    }
    let apiKey: APIKey = .deleteRecords
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// Each topic that we want to delete records from.
    let topics: [DeleteRecordsTopic]
    
    /// How long to wait for the deletion to complete, in milliseconds.
    let timeoutMs: Int32


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        buffer.write(timeoutMs)
        if apiVersion >= 2 {
            buffer.write(taggedFields)
        }
    }
}
