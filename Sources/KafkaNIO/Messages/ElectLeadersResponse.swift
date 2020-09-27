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


struct ElectLeadersResponse: KafkaResponse { 
    init(apiVersion: APIVersion, topic: String, partitionResult: [PartitionResult]) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.topic = topic
        self.partitionResult = partitionResult
    }
    let apiKey: APIKey = .electLeaders
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The top level response error code.
    let errorCode: ErrorCode?
    
    /// The election results, or an empty array if the requester did not have permission and the request asks for all partitions.
    let replicaElectionResults: [ReplicaElectionResult]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        if apiVersion >= 1 {
            errorCode = try buffer.read()
        } else { 
            errorCode = nil
        }
        replicaElectionResults = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 2 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32, errorCode: ErrorCode?, replicaElectionResults: [ReplicaElectionResult]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.errorCode = errorCode
        self.replicaElectionResults = replicaElectionResults
    }
}