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


struct IncrementalAlterConfigsRequest: KafkaRequest { 
    struct AlterConfigsResource: KafkaRequestStruct {
        struct AlterableConfig: KafkaRequestStruct {
        
            
            /// The configuration key name.
            let name: String    
            /// The type (Set, Delete, Append, Subtract) of operation.
            let configOperation: Int8    
            /// The value to set for the configuration key.
            let value: String?
            let taggedFields: [TaggedField] = []
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 1) ? .varint : .bigEndian
                buffer.write(name, lengthEncoding: lengthEncoding)
                buffer.write(configOperation)
                buffer.write(value, lengthEncoding: lengthEncoding)
                if apiVersion >= 1 {
                    buffer.write(taggedFields)
                }
            
            }
        }
    
        
        /// The resource type.
        let resourceType: Int8    
        /// The resource name.
        let resourceName: String    
        /// The configurations.
        let configs: [AlterableConfig]
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 1) ? .varint : .bigEndian
            buffer.write(resourceType)
            buffer.write(resourceName, lengthEncoding: lengthEncoding)
            try buffer.write(configs, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 1 {
                buffer.write(taggedFields)
            }
        
        }
    }
    let apiKey: APIKey = .incrementalAlterConfigs
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The incremental updates for each resource.
    let resources: [AlterConfigsResource]
    
    /// True if we should validate the request, but not change the configurations.
    let validateOnly: Bool


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 1) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(resources, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        buffer.write(validateOnly)
        if apiVersion >= 1 {
            buffer.write(taggedFields)
        }
    }
}
