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


struct FindCoordinatorRequest: KafkaRequest { 
    
    let apiKey: APIKey = .findCoordinator
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The coordinator key.
    let key: String
    
    /// The coordinator key type.  (Group, transaction, etc.)
    let keyType: CoordinatorType?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 3) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(key, lengthEncoding: lengthEncoding)
        if apiVersion >= 1 {
            guard let keyType = self.keyType else {
                throw KafkaError.missingValue
            }
            buffer.write(keyType)
        }
        if apiVersion >= 3 {
            buffer.write(taggedFields)
        }
    }
}
