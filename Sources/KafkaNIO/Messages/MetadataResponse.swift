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
    init(apiVersion: APIVersion, nodeID: Int32, host: String, port: Int32, rack: String?) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.nodeID = nodeID
        self.host = host
        self.port = port
        self.rack = rack
    }
    
    init(apiVersion: APIVersion, errorCode: ErrorCode, name: String, isInternal: Bool?, partitions: [MetadataResponsePartition], topicAuthorizedOperations: Int32?) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.errorCode = errorCode
        self.name = name
        self.isInternal = isInternal
        self.partitions = partitions
        self.topicAuthorizedOperations = topicAuthorizedOperations
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
