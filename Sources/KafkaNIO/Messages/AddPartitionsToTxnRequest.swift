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


struct AddPartitionsToTxnRequest: KafkaRequest { 
    init(apiVersion: APIVersion, name: String, partitions: [Int32]) {
        self.apiVersion = apiVersion
        self.name = name
        self.partitions = partitions
    }
    let apiKey: APIKey = .addPartitionsToTxn
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The transactional id corresponding to the transaction.
    let transactionalID: String
    
    /// Current producer id in use by the transactional id.
    let producerID: Int64
    
    /// Current epoch associated with the producer id.
    let producerEpoch: Int16
    
    /// The partitions to add to the transaction.
    let topics: [AddPartitionsToTxnTopic]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(transactionalID, lengthEncoding: lengthEncoding)
        buffer.write(producerID)
        buffer.write(producerEpoch)
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }
}
