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


struct RenewDelegationTokenRequest: KafkaRequest { 
    
    let apiKey: APIKey = .renewDelegationToken
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The HMAC of the delegation token to be renewed.
    let hmac: [UInt8]
    
    /// The renewal time period in milliseconds.
    let renewPeriodMs: Int64


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(hmac, lengthEncoding: lengthEncoding)
        buffer.write(renewPeriodMs)
        if apiVersion >= 2 {
            buffer.write(taggedFields)
        }
    }
}
