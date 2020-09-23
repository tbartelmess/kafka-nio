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
    struct ComponentData: KafkaRequestStruct {
    
        
        /// The entity type that the filter component applies to.
        let entityType: String    
        /// How to match the entity {0 = exact name, 1 = default name, 2 = any specified name}.
        let matchType: Int8    
        /// The string to match against, or null if unused for the match type.
        let match: String?
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            buffer.write(entityType, lengthEncoding: lengthEncoding)
            buffer.write(matchType)
            buffer.write(match, lengthEncoding: lengthEncoding)
    
        
        }
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
