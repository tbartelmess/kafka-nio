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


struct StopReplicaRequest: KafkaRequest { 
    struct StopReplicaPartitionV0: KafkaRequestStruct {
    
        
        /// The topic name.
        let topicName: String?    
        /// The partition index.
        let partitionIndex: Int32?
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            if apiVersion <= 0 {
                guard let topicName = self.topicName else {
                    throw KafkaError.missingValue
                }
                buffer.write(topicName, lengthEncoding: lengthEncoding)
            }
            if apiVersion <= 0 {
                guard let partitionIndex = self.partitionIndex else {
                    throw KafkaError.missingValue
                }
                buffer.write(partitionIndex)
            }
            if apiVersion >= 2 {
                buffer.write(taggedFields)
            }
        }
    
        init(topicName: String?, partitionIndex: Int32?) {
            self.topicName = topicName
            self.partitionIndex = partitionIndex
        }
    
    }
    
    
    struct StopReplicaTopicV1: KafkaRequestStruct {
    
        
        /// The topic name.
        let name: String?    
        /// The partition indexes.
        let partitionIndexes: [Int32]?
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            if apiVersion >= 1 && apiVersion <= 2 {
                guard let name = self.name else {
                    throw KafkaError.missingValue
                }
                buffer.write(name, lengthEncoding: lengthEncoding)
            }
            if apiVersion >= 1 && apiVersion <= 2 {
                guard let partitionIndexes = self.partitionIndexes else {
                    throw KafkaError.missingValue
                }
                buffer.write(partitionIndexes, lengthEncoding: lengthEncoding)
            }
            if apiVersion >= 2 {
                buffer.write(taggedFields)
            }
        }
    
        init(name: String?, partitionIndexes: [Int32]?) {
            self.name = name
            self.partitionIndexes = partitionIndexes
        }
    
    }
    
    
    struct StopReplicaTopicState: KafkaRequestStruct {
        struct StopReplicaPartitionState: KafkaRequestStruct {
        
            
            /// The partition index.
            let partitionIndex: Int32?    
            /// The leader epoch.
            let leaderEpoch: Int32?    
            /// Whether this partition should be deleted.
            let deletePartition: Bool?
            let taggedFields: [TaggedField] = []
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                if apiVersion >= 3 {
                    guard let partitionIndex = self.partitionIndex else {
                        throw KafkaError.missingValue
                    }
                    buffer.write(partitionIndex)
                }
                if apiVersion >= 3 {
                    guard let leaderEpoch = self.leaderEpoch else {
                        throw KafkaError.missingValue
                    }
                    buffer.write(leaderEpoch)
                }
                if apiVersion >= 3 {
                    guard let deletePartition = self.deletePartition else {
                        throw KafkaError.missingValue
                    }
                    buffer.write(deletePartition)
                }
                if apiVersion >= 2 {
                    buffer.write(taggedFields)
                }
            }
        
            init(partitionIndex: Int32?, leaderEpoch: Int32?, deletePartition: Bool?) {
                self.partitionIndex = partitionIndex
                self.leaderEpoch = leaderEpoch
                self.deletePartition = deletePartition
            }
        
        }
    
        
        /// The topic name.
        let topicName: String?    
        /// The state of each partition
        let partitionStates: [StopReplicaPartitionState]?
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            if apiVersion >= 3 {
                guard let topicName = self.topicName else {
                    throw KafkaError.missingValue
                }
                buffer.write(topicName, lengthEncoding: lengthEncoding)
            }
            if apiVersion >= 3 {
                guard let partitionStates = self.partitionStates else {
                    throw KafkaError.missingValue
                }
                try buffer.write(partitionStates, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            }
            if apiVersion >= 2 {
                buffer.write(taggedFields)
            }
        }
    
        init(topicName: String?, partitionStates: [StopReplicaPartitionState]?) {
            self.topicName = topicName
            self.partitionStates = partitionStates
        }
    
    }
    
    let apiKey: APIKey = .stopReplica
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
    
    /// Whether these partitions should be deleted.
    let deletePartitions: Bool?
    
    /// The partitions to stop.
    let ungroupedPartitions: [StopReplicaPartitionV0]?
    
    /// The topics to stop.
    let topics: [StopReplicaTopicV1]?
    
    /// Each topic.
    let topicStates: [StopReplicaTopicState]?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(controllerID)
        buffer.write(controllerEpoch)
        if apiVersion >= 1 {
            guard let brokerEpoch = self.brokerEpoch else {
                throw KafkaError.missingValue
            }
            buffer.write(brokerEpoch)
        }
        if apiVersion <= 2 {
            guard let deletePartitions = self.deletePartitions else {
                throw KafkaError.missingValue
            }
            buffer.write(deletePartitions)
        }
        if apiVersion <= 0 {
            guard let ungroupedPartitions = self.ungroupedPartitions else {
                throw KafkaError.missingValue
            }
            try buffer.write(ungroupedPartitions, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 1 && apiVersion <= 2 {
            guard let topics = self.topics else {
                throw KafkaError.missingValue
            }
            try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 3 {
            guard let topicStates = self.topicStates else {
                throw KafkaError.missingValue
            }
            try buffer.write(topicStates, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 2 {
            buffer.write(taggedFields)
        }
    }
}
