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


struct SaslHandshakeRequest: KafkaRequest { 
    
    let apiKey: APIKey = .saslHandshake
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The SASL mechanism chosen by the client.
    let mechanism: String


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(mechanism, lengthEncoding: lengthEncoding)
    }
}
