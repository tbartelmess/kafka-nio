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


struct ProduceRequest: KafkaRequest { 
    init(apiVersion: APIVersion, name: String, partitions: [PartitionProduceData]) {
        self.apiVersion = apiVersion
        self.name = name
        self.partitions = partitions
    }
    let apiKey: APIKey = .produce
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The transactional ID, or null if the producer is not transactional.
    let transactionalID: String?
    
    /// The number of acknowledgments the producer requires the leader to have received before considering a request complete. Allowed values: 0 for no acknowledgments, 1 for only the leader and -1 for the full ISR.
    let acks: Int16
    
    /// The timeout to await a response in miliseconds.
    let timeoutMs: Int32
    
    /// Each topic to produce to.
    let topics: [TopicProduceData]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        if apiVersion >= 3 {
            guard let transactionalID = self.transactionalID else {
                throw KafkaError.missingValue
            }
            buffer.write(transactionalID, lengthEncoding: lengthEncoding)
        }
        buffer.write(acks)
        buffer.write(timeoutMs)
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }
}
