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


struct FetchResponse: KafkaResponse { 
    init(apiVersion: APIVersion, topic: String, partitionResponses: [FetchablePartitionResponse]) {
        self.apiVersion = apiVersion
        self.topic = topic
        self.partitionResponses = partitionResponses
    }
    let apiKey: APIKey = .fetch
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// The top level response error code.
    let errorCode: ErrorCode?
    
    /// The fetch session ID, or 0 if this is not part of a fetch session.
    let sessionID: Int32?
    
    /// The response topics.
    let responses: [FetchableTopicResponse]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        if apiVersion >= 1 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
        if apiVersion >= 7 {
            errorCode = try buffer.read()
        } else { 
            errorCode = nil
        }
        if apiVersion >= 7 {
            sessionID = try buffer.read()
        } else { 
            sessionID = nil
        }
        responses = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32?, errorCode: ErrorCode?, sessionID: Int32?, responses: [FetchableTopicResponse]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.throttleTimeMs = throttleTimeMs
        self.errorCode = errorCode
        self.sessionID = sessionID
        self.responses = responses
    }
}