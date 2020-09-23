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


struct CreateTopicsResponse: KafkaResponse { 
    struct CreatableTopicResult: KafkaResponseStruct {
        struct CreatableTopicConfigs: KafkaResponseStruct {
        
            
            /// The configuration name.
            let name: String?    
            /// The configuration value.
            let value: String?    
            /// True if the configuration is read-only.
            let readOnly: Bool?    
            /// The configuration source.
            let configSource: Int8?    
            /// True if this configuration is sensitive.
            let isSensitive: Bool?
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 5) ? .varint : .bigEndian
                if apiVersion >= 5 {
                    name = try buffer.read(lengthEncoding: lengthEncoding)
                } else { 
                    name = nil
                }
                if apiVersion >= 5 {
                    value = try buffer.read(lengthEncoding: lengthEncoding)
                } else { 
                    value = nil
                }
                if apiVersion >= 5 {
                    readOnly = try buffer.read()
                } else { 
                    readOnly = nil
                }
                if apiVersion >= 5 {
                    configSource = try buffer.read()
                } else { 
                    configSource = nil
                }
                if apiVersion >= 5 {
                    isSensitive = try buffer.read()
                } else { 
                    isSensitive = nil
                }
                if apiVersion >= 5 {
                    let _ : [TaggedField] = try buffer.read()
                }
            }
        
        }
    
        
        /// The topic name.
        let name: String    
        /// The error code, or 0 if there was no error.
        let errorCode: ErrorCode    
        /// The error message, or null if there was no error.
        let errorMessage: String?    
        /// Optional topic config error returned if configs are not returned in the response.
        let topicConfigErrorCode: Int16?    
        /// Number of partitions of the topic.
        let numPartitions: Int32?    
        /// Replication factor of the topic.
        let replicationFactor: Int16?    
        /// Configuration of the topic.
        let configs: [CreatableTopicConfigs]?
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 5) ? .varint : .bigEndian
            name = try buffer.read(lengthEncoding: lengthEncoding)
            errorCode = try buffer.read()
            if apiVersion >= 1 {
                errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
            } else { 
                errorMessage = nil
            }
            if apiVersion >= 5 {
                topicConfigErrorCode = try buffer.read()
            } else { 
                topicConfigErrorCode = nil
            }
            if apiVersion >= 5 {
                numPartitions = try buffer.read()
            } else { 
                numPartitions = nil
            }
            if apiVersion >= 5 {
                replicationFactor = try buffer.read()
            } else { 
                replicationFactor = nil
            }
            if apiVersion >= 5 {
                configs = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            } else { 
                configs = nil
            }
            if apiVersion >= 5 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
    
    }
    let apiKey: APIKey = .createTopics
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// Results for each topic we tried to create.
    let topics: [CreatableTopicResult]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 5) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        if apiVersion >= 2 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
        topics = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 5 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }
}