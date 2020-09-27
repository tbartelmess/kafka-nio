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


struct LeaderAndIsrRequest: KafkaRequest { 
    init(apiVersion: APIVersion, topicName: String?, partitionStates: [[UInt8]]?) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.topicName = topicName
        self.partitionStates = partitionStates
    }
    
    init(apiVersion: APIVersion, brokerID: Int32, hostName: String, port: Int32) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.brokerID = brokerID
        self.hostName = hostName
        self.port = port
    }
    let apiKey: APIKey = .leaderAndIsr
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The current controller ID.
    let controllerID: Int32
    
    /// The current controller epoch.
    let controllerEpoch: Int32
    
    /// The current broker epoch.
    let brokerEpoch: Int64?
    
    /// The state of each partition, in a v0 or v1 message.
    let ungroupedPartitionStates: [[UInt8]]?
    
    /// Each topic.
    let topicStates: [LeaderAndIsrTopicState]?
    
    /// The current live leaders.
    let liveLeaders: [LeaderAndIsrLiveLeader]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 4) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(controllerID)
        buffer.write(controllerEpoch)
        if apiVersion >= 2 {
            guard let brokerEpoch = self.brokerEpoch else {
                throw KafkaError.missingValue
            }
            buffer.write(brokerEpoch)
        }
        if apiVersion <= 1 {
            guard let ungroupedPartitionStates = self.ungroupedPartitionStates else {
                throw KafkaError.missingValue
            }
            buffer.write(ungroupedPartitionStates, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 2 {
            guard let topicStates = self.topicStates else {
                throw KafkaError.missingValue
            }
            try buffer.write(topicStates, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        try buffer.write(liveLeaders, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 4 {
            buffer.write(taggedFields)
        }
    }
}
