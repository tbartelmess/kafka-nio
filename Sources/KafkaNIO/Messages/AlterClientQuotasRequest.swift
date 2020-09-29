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
    struct EntryData: KafkaRequestStruct {
        struct EntityData: KafkaRequestStruct {
        
            
            /// The entity type.
            let entityType: String    
            /// The name of the entity, or null if the default.
            let entityName: String?
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = .bigEndian
                buffer.write(entityType, lengthEncoding: lengthEncoding)
                buffer.write(entityName, lengthEncoding: lengthEncoding)
        
            }
        
            init(entityType: String, entityName: String?) {
                self.entityType = entityType
                self.entityName = entityName
            }
        
        }
        struct OpData: KafkaRequestStruct {
        
            
            /// The quota configuration key.
            let key: String    
            /// The value to set, otherwise ignored if the value is to be removed.
            let value: Float64    
            /// Whether the quota configuration value should be removed, otherwise set.
            let remove: Bool
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = .bigEndian
                buffer.write(key, lengthEncoding: lengthEncoding)
                buffer.write(value)
                buffer.write(remove)
        
            }
        
            init(key: String, value: Float64, remove: Bool) {
                self.key = key
                self.value = value
                self.remove = remove
            }
        
        }
    
        
        /// The quota entity to alter.
        let entity: [EntityData]    
        /// An individual quota configuration entry to alter.
        let ops: [OpData]
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            try buffer.write(entity, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            try buffer.write(ops, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    
        }
    
        init(entity: [EntityData], ops: [OpData]) {
            self.entity = entity
            self.ops = ops
        }
    
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
