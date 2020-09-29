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


struct AlterConfigsRequest: KafkaRequest { 
    struct AlterConfigsResource: KafkaRequestStruct {
        struct AlterableConfig: KafkaRequestStruct {
        
            
            /// The configuration key name.
            let name: String    
            /// The value to set for the configuration key.
            let value: String?
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = .bigEndian
                buffer.write(name, lengthEncoding: lengthEncoding)
                buffer.write(value, lengthEncoding: lengthEncoding)
        
            }
        
            init(name: String, value: String?) {
                self.name = name
                self.value = value
            }
        
        }
    
        
        /// The resource type.
        let resourceType: Int8    
        /// The resource name.
        let resourceName: String    
        /// The configurations.
        let configs: [AlterableConfig]
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            buffer.write(resourceType)
            buffer.write(resourceName, lengthEncoding: lengthEncoding)
            try buffer.write(configs, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    
        }
    
        init(resourceType: Int8, resourceName: String, configs: [AlterableConfig]) {
            self.resourceType = resourceType
            self.resourceName = resourceName
            self.configs = configs
        }
    
    }
    
    let apiKey: APIKey = .alterConfigs
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The updates for each resource.
    let resources: [AlterConfigsResource]
    
    /// True if we should validate the request, but not change the configurations.
    let validateOnly: Bool


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(resources, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        buffer.write(validateOnly)
    }
}
