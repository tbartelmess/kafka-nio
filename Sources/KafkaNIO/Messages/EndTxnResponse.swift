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


struct EndTxnResponse: KafkaResponse { 
    
    let apiKey: APIKey = .endTxn
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    
    /// The error code, or 0 if there was no error.
    let errorCode: ErrorCode


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        throttleTimeMs = try buffer.read()
        errorCode = try buffer.read()
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32, errorCode: ErrorCode) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.throttleTimeMs = throttleTimeMs
        self.errorCode = errorCode
    }
}