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


struct CreateDelegationTokenResponse: KafkaResponse { 
    
    let apiKey: APIKey = .createDelegationToken
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The top-level error, or zero if there was no error.
    let errorCode: ErrorCode
    
    /// The principal type of the token owner.
    let principalType: String
    
    /// The name of the token owner.
    let principalName: String
    
    /// When this token was generated.
    let issueTimestampMs: Int64
    
    /// When this token expires.
    let expiryTimestampMs: Int64
    
    /// The maximum lifetime of this token.
    let maxTimestampMs: Int64
    
    /// The token UUID.
    let tokenID: String
    
    /// HMAC of the delegation token.
    let hmac: [UInt8]
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        errorCode = try buffer.read()
        principalType = try buffer.read(lengthEncoding: lengthEncoding)
        principalName = try buffer.read(lengthEncoding: lengthEncoding)
        issueTimestampMs = try buffer.read()
        expiryTimestampMs = try buffer.read()
        maxTimestampMs = try buffer.read()
        tokenID = try buffer.read(lengthEncoding: lengthEncoding)
        hmac = try buffer.read(lengthEncoding: lengthEncoding)
        throttleTimeMs = try buffer.read()
        if apiVersion >= 2 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, errorCode: ErrorCode, principalType: String, principalName: String, issueTimestampMs: Int64, expiryTimestampMs: Int64, maxTimestampMs: Int64, tokenID: String, hmac: [UInt8], throttleTimeMs: Int32) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.errorCode = errorCode
        self.principalType = principalType
        self.principalName = principalName
        self.issueTimestampMs = issueTimestampMs
        self.expiryTimestampMs = expiryTimestampMs
        self.maxTimestampMs = maxTimestampMs
        self.tokenID = tokenID
        self.hmac = hmac
        self.throttleTimeMs = throttleTimeMs
    }
}