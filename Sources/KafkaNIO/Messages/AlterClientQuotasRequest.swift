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


struct AlterClientQuotasRequest: KafkaRequest { 
    init(apiVersion: APIVersion, entity: [EntityData], ops: [OpData]) {
        self.apiVersion = apiVersion
        self.entity = entity
        self.ops = ops
    }
    let apiKey: APIKey = .alterClientQuotas
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The quota configuration entries to alter.
    let entries: [EntryData]
    
    /// Whether the alteration should be validated, but not performed.
    let validateOnly: Bool


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(entries, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        buffer.write(validateOnly)
    }
}
