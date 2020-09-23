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


struct EndTxnRequest: KafkaRequest { 
    
    let apiKey: APIKey = .endTxn
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The ID of the transaction to end.
    let transactionalID: String
    
    /// The producer ID.
    let producerID: Int64
    
    /// The current epoch associated with the producer.
    let producerEpoch: Int16
    
    /// True if the transaction was committed, false if it was aborted.
    let committed: Bool


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(transactionalID, lengthEncoding: lengthEncoding)
        buffer.write(producerID)
        buffer.write(producerEpoch)
        buffer.write(committed)
    }
}
