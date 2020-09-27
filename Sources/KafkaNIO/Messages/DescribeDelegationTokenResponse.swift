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


struct DescribeDelegationTokenResponse: KafkaResponse { 
    init(apiVersion: APIVersion, principalType: String, principalName: String, issueTimestamp: Int64, expiryTimestamp: Int64, maxTimestamp: Int64, tokenID: String, hmac: [UInt8], renewers: [DescribedDelegationTokenRenewer]) {
        self.apiVersion = apiVersion
        self.taggedFields = []
        self.principalType = principalType
        self.principalName = principalName
        self.issueTimestamp = issueTimestamp
        self.expiryTimestamp = expiryTimestamp
        self.maxTimestamp = maxTimestamp
        self.tokenID = tokenID
        self.hmac = hmac
        self.renewers = renewers
    }
    let apiKey: APIKey = .describeDelegationToken
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// The tokens.
    let tokens: [DescribedDelegationToken]
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        errorCode = try buffer.read()
        tokens = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        throttleTimeMs = try buffer.read()
        if apiVersion >= 2 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, errorCode: ErrorCode, tokens: [DescribedDelegationToken], throttleTimeMs: Int32) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.errorCode = errorCode
        self.tokens = tokens
        self.throttleTimeMs = throttleTimeMs
    }
}