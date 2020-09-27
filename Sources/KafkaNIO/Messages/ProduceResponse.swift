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


struct ProduceResponse: KafkaResponse { 
    init(apiVersion: APIVersion, name: String, partitions: [PartitionProduceResponse]) {
        self.apiVersion = apiVersion
        self.name = name
        self.partitions = partitions
    }
    let apiKey: APIKey = .produce
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// Each produce response
    let responses: [TopicProduceResponse]
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        responses = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 1 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, responses: [TopicProduceResponse], throttleTimeMs: Int32?) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.responses = responses
        self.throttleTimeMs = throttleTimeMs
    }
}