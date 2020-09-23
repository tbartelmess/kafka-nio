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


struct AlterClientQuotasResponse: KafkaResponse { 
    struct EntryData: KafkaResponseStruct {
        struct EntityData: KafkaResponseStruct {
        
            
            /// The entity type.
            let entityType: String    
            /// The name of the entity, or null if the default.
            let entityName: String?
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = .bigEndian
                entityType = try buffer.read(lengthEncoding: lengthEncoding)
                entityName = try buffer.read(lengthEncoding: lengthEncoding)
            }
        
        }
    
        
        /// The error code, or `0` if the quota alteration succeeded.
        let errorCode: ErrorCode    
        /// The error message, or `null` if the quota alteration succeeded.
        let errorMessage: String?    
        /// The quota entity to alter.
        let entity: [EntityData]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            errorCode = try buffer.read()
            errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
            entity = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
    
    }
    let apiKey: APIKey = .alterClientQuotas
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The quota configuration entries to alter.
    let entries: [EntryData]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        entries = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }
}