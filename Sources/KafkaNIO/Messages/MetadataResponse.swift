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


struct MetadataResponse: KafkaResponse { 
    struct MetadataResponseBroker: KafkaResponseStruct {
    
        
        /// The broker ID.
        let nodeID: Int32    
        /// The broker hostname.
        let host: String    
        /// The broker port.
        let port: Int32    
        /// The rack of the broker, or null if it has not been assigned to a rack.
        let rack: String?
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 9) ? .varint : .bigEndian
            nodeID = try buffer.read()
            host = try buffer.read(lengthEncoding: lengthEncoding)
            port = try buffer.read()
            if apiVersion >= 1 {
                rack = try buffer.read(lengthEncoding: lengthEncoding)
            } else { 
                rack = nil
            }
            if apiVersion >= 9 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(nodeID: Int32, host: String, port: Int32, rack: String?) {
            self.nodeID = nodeID
            self.host = host
            self.port = port
            self.rack = rack
        }
    
    }
    
    
    struct MetadataResponseTopic: KafkaResponseStruct {
        struct MetadataResponsePartition: KafkaResponseStruct {
        
            
            /// The partition error, or 0 if there was no error.
            let errorCode: ErrorCode    
            /// The partition index.
            let partitionIndex: Int32    
            /// The ID of the leader broker.
            let leaderID: Int32    
            /// The leader epoch of this partition.
            let leaderEpoch: Int32?    
            /// The set of all nodes that host this partition.
            let replicaNodes: [Int32]    
            /// The set of nodes that are in sync with the leader for this partition.
            let isrNodes: [Int32]    
            /// The set of offline replicas of this partition.
            let offlineReplicas: [Int32]?
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 9) ? .varint : .bigEndian
                errorCode = try buffer.read()
                partitionIndex = try buffer.read()
                leaderID = try buffer.read()
                if apiVersion >= 7 {
                    leaderEpoch = try buffer.read()
                } else { 
                    leaderEpoch = nil
                }
                replicaNodes = try buffer.read(lengthEncoding: lengthEncoding)
                isrNodes = try buffer.read(lengthEncoding: lengthEncoding)
                if apiVersion >= 5 {
                    offlineReplicas = try buffer.read(lengthEncoding: lengthEncoding)
                } else { 
                    offlineReplicas = nil
                }
                if apiVersion >= 9 {
                    let _ : [TaggedField] = try buffer.read()
                }
            }
            init(errorCode: ErrorCode, partitionIndex: Int32, leaderID: Int32, leaderEpoch: Int32?, replicaNodes: [Int32], isrNodes: [Int32], offlineReplicas: [Int32]?) {
                self.errorCode = errorCode
                self.partitionIndex = partitionIndex
                self.leaderID = leaderID
                self.leaderEpoch = leaderEpoch
                self.replicaNodes = replicaNodes
                self.isrNodes = isrNodes
                self.offlineReplicas = offlineReplicas
            }
        
        }
    
        
        /// The topic error, or 0 if there was no error.
        let errorCode: ErrorCode    
        /// The topic name.
        let name: String    
        /// True if the topic is internal.
        let isInternal: Bool?    
        /// Each partition in the topic.
        let partitions: [MetadataResponsePartition]    
        /// 32-bit bitfield to represent authorized operations for this topic.
        let topicAuthorizedOperations: Int32?
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 9) ? .varint : .bigEndian
            errorCode = try buffer.read()
            name = try buffer.read(lengthEncoding: lengthEncoding)
            if apiVersion >= 1 {
                isInternal = try buffer.read()
            } else { 
                isInternal = nil
            }
            partitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 8 {
                topicAuthorizedOperations = try buffer.read()
            } else { 
                topicAuthorizedOperations = nil
            }
            if apiVersion >= 9 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(errorCode: ErrorCode, name: String, isInternal: Bool?, partitions: [MetadataResponsePartition], topicAuthorizedOperations: Int32?) {
            self.errorCode = errorCode
            self.name = name
            self.isInternal = isInternal
            self.partitions = partitions
            self.topicAuthorizedOperations = topicAuthorizedOperations
        }
    
    }
    
    let apiKey: APIKey = .metadata
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// Each broker in the response.
    let brokers: [MetadataResponseBroker]
    
    /// The cluster ID that responding broker belongs to.
    let clusterID: String?
    
    /// The ID of the controller broker.
    let controllerID: Int32?
    
    /// Each topic in the response.
    let topics: [MetadataResponseTopic]
    
    /// 32-bit bitfield to represent authorized operations for this cluster.
    let clusterAuthorizedOperations: Int32?
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 9) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        if apiVersion >= 3 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
        brokers = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 2 {
            clusterID = try buffer.read(lengthEncoding: lengthEncoding)
        } else { 
            clusterID = nil
        }
        if apiVersion >= 1 {
            controllerID = try buffer.read()
        } else { 
            controllerID = nil
        }
        topics = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 8 {
            clusterAuthorizedOperations = try buffer.read()
        } else { 
            clusterAuthorizedOperations = nil
        }
        if apiVersion >= 9 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32?, brokers: [MetadataResponseBroker], clusterID: String?, controllerID: Int32?, topics: [MetadataResponseTopic], clusterAuthorizedOperations: Int32?) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.brokers = brokers
        self.clusterID = clusterID
        self.controllerID = controllerID
        self.topics = topics
        self.clusterAuthorizedOperations = clusterAuthorizedOperations
    }
}