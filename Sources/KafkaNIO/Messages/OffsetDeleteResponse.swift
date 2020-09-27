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


struct OffsetDeleteResponse: KafkaResponse { 
    init(apiVersion: APIVersion, name: String, partitions: [OffsetDeleteResponsePartition]) {
        self.apiVersion = apiVersion
        self.name = name
        self.partitions = partitions
    }
    let apiKey: APIKey = .offsetDelete
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The top-level error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The responses for each topic.
    let topics: [OffsetDeleteResponseTopic]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        errorCode = try buffer.read()
        throttleTimeMs = try buffer.read()
        topics = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, errorCode: ErrorCode, throttleTimeMs: Int32, topics: [OffsetDeleteResponseTopic]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.errorCode = errorCode
        self.throttleTimeMs = throttleTimeMs
        self.topics = topics
    }
}