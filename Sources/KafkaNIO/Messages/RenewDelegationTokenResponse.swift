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


struct RenewDelegationTokenResponse: KafkaResponse { 
    
    let apiKey: APIKey = .renewDelegationToken
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// The timestamp in milliseconds at which this token expires.
    let expiryTimestampMs: Int64
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        errorCode = try buffer.read()
        expiryTimestampMs = try buffer.read()
        throttleTimeMs = try buffer.read()
        if apiVersion >= 2 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }
}