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


struct DescribeClientQuotasRequest: KafkaRequest { 
    init(apiVersion: APIVersion, entityType: String, matchType: Int8, match: String?) {
        self.apiVersion = apiVersion
        self.entityType = entityType
        self.matchType = matchType
        self.match = match
    }
    let apiKey: APIKey = .describeClientQuotas
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// Filter components to apply to quota entities.
    let components: [ComponentData]
    
    /// Whether the match is strict, i.e. should exclude entities with unspecified entity types.
    let strict: Bool


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(components, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        buffer.write(strict)
    }
}
