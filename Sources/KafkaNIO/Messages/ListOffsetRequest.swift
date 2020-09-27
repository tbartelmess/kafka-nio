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


struct ListOffsetRequest: KafkaRequest { 
    init(apiVersion: APIVersion, name: String, partitions: [ListOffsetPartition]) {
        self.apiVersion = apiVersion
        self.name = name
        self.partitions = partitions
    }
    let apiKey: APIKey = .listOffset
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The broker ID of the requestor, or -1 if this request is being made by a normal consumer.
    let replicaID: Int32
    
    /// This setting controls the visibility of transactional records. Using READ_UNCOMMITTED (isolation_level = 0) makes all records visible. With READ_COMMITTED (isolation_level = 1), non-transactional and COMMITTED transactional records are visible. To be more concrete, READ_COMMITTED returns all data from offsets smaller than the current LSO (last stable offset), and enables the inclusion of the list of aborted transactions in the result, which allows consumers to discard ABORTED transactional records
    let isolationLevel: IsolationLevel?
    
    /// Each topic in the request.
    let topics: [ListOffsetTopic]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(replicaID)
        if apiVersion >= 2 {
            guard let isolationLevel = self.isolationLevel else {
                throw KafkaError.missingValue
            }
            buffer.write(isolationLevel)
        }
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }
}
