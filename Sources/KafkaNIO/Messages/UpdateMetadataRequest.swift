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
    init(apiVersion: APIVersion, topicName: String?, partitionStates: [[UInt8]]?) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.topicName = topicName
        self.partitionStates = partitionStates
    }
    
    init(apiVersion: APIVersion, id: Int32, v0Host: String?, v0Port: Int32?, endpoints: [UpdateMetadataEndpoint]?, rack: String?) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.id = id
        self.v0Host = v0Host
        self.v0Port = v0Port
        self.endpoints = endpoints
        self.rack = rack
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
