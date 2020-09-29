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


struct InitProducerIdResponse: KafkaResponse { 
    
    let apiKey: APIKey = .initProducerId
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// The current producer id.
    let producerID: Int64
    
    /// The current epoch associated with the producer id.
    let producerEpoch: Int16
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        errorCode = try buffer.read()
        producerID = try buffer.read()
        producerEpoch = try buffer.read()
        if apiVersion >= 2 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32, errorCode: ErrorCode, producerID: Int64, producerEpoch: Int16) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.errorCode = errorCode
        self.producerID = producerID
        self.producerEpoch = producerEpoch
    }
}