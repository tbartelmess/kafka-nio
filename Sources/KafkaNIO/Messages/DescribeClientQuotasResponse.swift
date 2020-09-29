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


struct DescribeClientQuotasResponse: KafkaResponse { 
    struct EntryData: KafkaResponseStruct {
        struct EntityData: KafkaResponseStruct {
        
            
            /// The entity type.
            let entityType: String    
            /// The entity name, or null if the default.
            let entityName: String?
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = .bigEndian
                entityType = try buffer.read(lengthEncoding: lengthEncoding)
                entityName = try buffer.read(lengthEncoding: lengthEncoding)
            }
            init(entityType: String, entityName: String?) {
                self.entityType = entityType
                self.entityName = entityName
            }
        
        }
        struct ValueData: KafkaResponseStruct {
        
            
            /// The quota configuration key.
            let key: String    
            /// The quota configuration value.
            let value: Float64
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = .bigEndian
                key = try buffer.read(lengthEncoding: lengthEncoding)
                value = try buffer.read()
            }
            init(key: String, value: Float64) {
                self.key = key
                self.value = value
            }
        
        }
    
        
        /// The quota entity description.
        let entity: [EntityData]    
        /// The quota values for the entity.
        let values: [ValueData]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            entity = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            values = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        init(entity: [EntityData], values: [ValueData]) {
            self.entity = entity
            self.values = values
        }
    
    }
    
    let apiKey: APIKey = .describeClientQuotas
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The error code, or `0` if the quota description succeeded.
    let errorCode: ErrorCode
    
    /// The error message, or `null` if the quota description succeeded.
    let errorMessage: String?
    
    /// A result entry.
    let entries: [EntryData]?


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        errorCode = try buffer.read()
        errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
        entries = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32, errorCode: ErrorCode, errorMessage: String?, entries: [EntryData]?) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.throttleTimeMs = throttleTimeMs
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.entries = entries
    }
}