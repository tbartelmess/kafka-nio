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


struct DescribeConfigsResponse: KafkaResponse { 
    struct DescribeConfigsResult: KafkaResponseStruct {
        struct DescribeConfigsResourceResult: KafkaResponseStruct {
            struct DescribeConfigsSynonym: KafkaResponseStruct {
            
                
                /// The synonym name.
                let name: String?    
                /// The synonym value.
                let value: String?    
                /// The synonym source.
                let source: Int8?
                init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                    let lengthEncoding: IntegerEncoding = .bigEndian
                    if apiVersion >= 1 {
                        name = try buffer.read(lengthEncoding: lengthEncoding)
                    } else { 
                        name = nil
                    }
                    if apiVersion >= 1 {
                        value = try buffer.read(lengthEncoding: lengthEncoding)
                    } else { 
                        value = nil
                    }
                    if apiVersion >= 1 {
                        source = try buffer.read()
                    } else { 
                        source = nil
                    }
                }
                init(name: String?, value: String?, source: Int8?) {
                    self.name = name
                    self.value = value
                    self.source = source
                }
            
            }
        
            
            /// The configuration name.
            let name: String    
            /// The configuration value.
            let value: String?    
            /// True if the configuration is read-only.
            let readOnly: Bool    
            /// True if the configuration is not set.
            let isDefault: Bool?    
            /// The configuration source.
            let configSource: Int8?    
            /// True if this configuration is sensitive.
            let isSensitive: Bool    
            /// The synonyms for this configuration key.
            let synonyms: [DescribeConfigsSynonym]?    
            /// The configuration data type. Type can be one of the following values - BOOLEAN, STRING, INT, SHORT, LONG, DOUBLE, LIST, CLASS, PASSWORD
            let configType: Int8?    
            /// The configuration documentation.
            let documentation: String?
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = .bigEndian
                name = try buffer.read(lengthEncoding: lengthEncoding)
                value = try buffer.read(lengthEncoding: lengthEncoding)
                readOnly = try buffer.read()
                if apiVersion <= 0 {
                    isDefault = try buffer.read()
                } else { 
                    isDefault = nil
                }
                if apiVersion >= 1 {
                    configSource = try buffer.read()
                } else { 
                    configSource = nil
                }
                isSensitive = try buffer.read()
                if apiVersion >= 1 {
                    synonyms = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
                } else { 
                    synonyms = nil
                }
                if apiVersion >= 3 {
                    configType = try buffer.read()
                } else { 
                    configType = nil
                }
                if apiVersion >= 3 {
                    documentation = try buffer.read(lengthEncoding: lengthEncoding)
                } else { 
                    documentation = nil
                }
            }
            init(name: String, value: String?, readOnly: Bool, isDefault: Bool?, configSource: Int8?, isSensitive: Bool, synonyms: [DescribeConfigsSynonym]?, configType: Int8?, documentation: String?) {
                self.name = name
                self.value = value
                self.readOnly = readOnly
                self.isDefault = isDefault
                self.configSource = configSource
                self.isSensitive = isSensitive
                self.synonyms = synonyms
                self.configType = configType
                self.documentation = documentation
            }
        
        }
    
        
        /// The error code, or 0 if we were able to successfully describe the configurations.
        let errorCode: ErrorCode    
        /// The error message, or null if we were able to successfully describe the configurations.
        let errorMessage: String?    
        /// The resource type.
        let resourceType: Int8    
        /// The resource name.
        let resourceName: String    
        /// Each listed configuration.
        let configs: [DescribeConfigsResourceResult]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            errorCode = try buffer.read()
            errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
            resourceType = try buffer.read()
            resourceName = try buffer.read(lengthEncoding: lengthEncoding)
            configs = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        init(errorCode: ErrorCode, errorMessage: String?, resourceType: Int8, resourceName: String, configs: [DescribeConfigsResourceResult]) {
            self.errorCode = errorCode
            self.errorMessage = errorMessage
            self.resourceType = resourceType
            self.resourceName = resourceName
            self.configs = configs
        }
    
    }
    
    let apiKey: APIKey = .describeConfigs
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The results for each resource.
    let results: [DescribeConfigsResult]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        results = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32, results: [DescribeConfigsResult]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.throttleTimeMs = throttleTimeMs
        self.results = results
    }
}