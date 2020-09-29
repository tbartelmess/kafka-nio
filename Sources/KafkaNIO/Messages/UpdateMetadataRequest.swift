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


struct UpdateMetadataRequest: KafkaRequest { 
    struct UpdateMetadataTopicState: KafkaRequestStruct {
    
        
        /// The topic name.
        let topicName: String?    
        /// The partition that we would like to update.
        let partitionStates: [[UInt8]]?
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 6) ? .varint : .bigEndian
            if apiVersion >= 5 {
                guard let topicName = self.topicName else {
                    throw KafkaError.missingValue
                }
                buffer.write(topicName, lengthEncoding: lengthEncoding)
            }
            if apiVersion >= 5 {
                guard let partitionStates = self.partitionStates else {
                    throw KafkaError.missingValue
                }
                buffer.write(partitionStates, lengthEncoding: lengthEncoding)
            }
            if apiVersion >= 6 {
                buffer.write(taggedFields)
            }
        }
    
        init(topicName: String?, partitionStates: [[UInt8]]?) {
            self.topicName = topicName
            self.partitionStates = partitionStates
        }
    
    }
    
    
    struct UpdateMetadataBroker: KafkaRequestStruct {
        struct UpdateMetadataEndpoint: KafkaRequestStruct {
        
            
            /// The port of this endpoint
            let port: Int32?    
            /// The hostname of this endpoint
            let host: String?    
            /// The listener name.
            let listener: String?    
            /// The security protocol type.
            let securityProtocol: Int16?
            let taggedFields: [TaggedField] = []
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 6) ? .varint : .bigEndian
                if apiVersion >= 1 {
                    guard let port = self.port else {
                        throw KafkaError.missingValue
                    }
                    buffer.write(port)
                }
                if apiVersion >= 1 {
                    guard let host = self.host else {
                        throw KafkaError.missingValue
                    }
                    buffer.write(host, lengthEncoding: lengthEncoding)
                }
                if apiVersion >= 3 {
                    guard let listener = self.listener else {
                        throw KafkaError.missingValue
                    }
                    buffer.write(listener, lengthEncoding: lengthEncoding)
                }
                if apiVersion >= 1 {
                    guard let securityProtocol = self.securityProtocol else {
                        throw KafkaError.missingValue
                    }
                    buffer.write(securityProtocol)
                }
                if apiVersion >= 6 {
                    buffer.write(taggedFields)
                }
            }
        
            init(port: Int32?, host: String?, listener: String?, securityProtocol: Int16?) {
                self.port = port
                self.host = host
                self.listener = listener
                self.securityProtocol = securityProtocol
            }
        
        }
    
        
        /// The broker id.
        let id: Int32    
        /// The broker hostname.
        let v0Host: String?    
        /// The broker port.
        let v0Port: Int32?    
        /// The broker endpoints.
        let endpoints: [UpdateMetadataEndpoint]?    
        /// The rack which this broker belongs to.
        let rack: String?
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 6) ? .varint : .bigEndian
            buffer.write(id)
            if apiVersion <= 0 {
                guard let v0Host = self.v0Host else {
                    throw KafkaError.missingValue
                }
                buffer.write(v0Host, lengthEncoding: lengthEncoding)
            }
            if apiVersion <= 0 {
                guard let v0Port = self.v0Port else {
                    throw KafkaError.missingValue
                }
                buffer.write(v0Port)
            }
            if apiVersion >= 1 {
                guard let endpoints = self.endpoints else {
                    throw KafkaError.missingValue
                }
                try buffer.write(endpoints, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            }
            if apiVersion >= 2 {
                guard let rack = self.rack else {
                    throw KafkaError.missingValue
                }
                buffer.write(rack, lengthEncoding: lengthEncoding)
            }
            if apiVersion >= 6 {
                buffer.write(taggedFields)
            }
        }
    
        init(id: Int32, v0Host: String?, v0Port: Int32?, endpoints: [UpdateMetadataEndpoint]?, rack: String?) {
            self.id = id
            self.v0Host = v0Host
            self.v0Port = v0Port
            self.endpoints = endpoints
            self.rack = rack
        }
    
    }
    
    let apiKey: APIKey = .updateMetadata
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The controller id.
    let controllerID: Int32
    
    /// The controller epoch.
    let controllerEpoch: Int32
    
    /// The broker epoch.
    let brokerEpoch: Int64?
    
    /// In older versions of this RPC, each partition that we would like to update.
    let ungroupedPartitionStates: [[UInt8]]?
    
    /// In newer versions of this RPC, each topic that we would like to update.
    let topicStates: [UpdateMetadataTopicState]?
    
    /// None
    let liveBrokers: [UpdateMetadataBroker]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 6) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(controllerID)
        buffer.write(controllerEpoch)
        if apiVersion >= 5 {
            guard let brokerEpoch = self.brokerEpoch else {
                throw KafkaError.missingValue
            }
            buffer.write(brokerEpoch)
        }
        if apiVersion <= 4 {
            guard let ungroupedPartitionStates = self.ungroupedPartitionStates else {
                throw KafkaError.missingValue
            }
            buffer.write(ungroupedPartitionStates, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 5 {
            guard let topicStates = self.topicStates else {
                throw KafkaError.missingValue
            }
            try buffer.write(topicStates, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        try buffer.write(liveBrokers, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 6 {
            buffer.write(taggedFields)
        }
    }
}
