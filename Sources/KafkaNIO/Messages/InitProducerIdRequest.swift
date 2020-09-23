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


struct InitProducerIdRequest: KafkaRequest { 
    
    let apiKey: APIKey = .initProducerId
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The transactional id, or null if the producer is not transactional.
    let transactionalID: String?
    
    /// The time in ms to wait before aborting idle transactions sent by this producer. This is only relevant if a TransactionalId has been defined.
    let transactionTimeoutMs: Int32
    
    /// The producer id. This is used to disambiguate requests if a transactional id is reused following its expiration.
    let producerID: Int64?
    
    /// The producer's current epoch. This will be checked against the producer epoch on the broker, and the request will return an error if they do not match.
    let producerEpoch: Int16?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(transactionalID, lengthEncoding: lengthEncoding)
        buffer.write(transactionTimeoutMs)
        if apiVersion >= 3 {
            guard let producerID = self.producerID else {
                throw KafkaError.missingValue
            }
            buffer.write(producerID)
        }
        if apiVersion >= 3 {
            guard let producerEpoch = self.producerEpoch else {
                throw KafkaError.missingValue
            }
            buffer.write(producerEpoch)
        }
        if apiVersion >= 2 {
            buffer.write(taggedFields)
        }
    }
}
