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
    struct DescribedDelegationToken: KafkaResponseStruct {
        struct DescribedDelegationTokenRenewer: KafkaResponseStruct {
        
            
            /// The renewer principal type
            let principalType: String    
            /// The renewer principal name
            let principalName: String
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
                principalType = try buffer.read(lengthEncoding: lengthEncoding)
                principalName = try buffer.read(lengthEncoding: lengthEncoding)
                if apiVersion >= 2 {
                    let _ : [TaggedField] = try buffer.read()
                }
            }
        
        }
    
        
        /// The token principal type.
        let principalType: String    
        /// The token principal name.
        let principalName: String    
        /// The token issue timestamp in milliseconds.
        let issueTimestamp: Int64    
        /// The token expiry timestamp in milliseconds.
        let expiryTimestamp: Int64    
        /// The token maximum timestamp length in milliseconds.
        let maxTimestamp: Int64    
        /// The token ID.
        let tokenID: String    
        /// The token HMAC.
        let hmac: [UInt8]    
        /// Those who are able to renew this token before it expires.
        let renewers: [DescribedDelegationTokenRenewer]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            principalType = try buffer.read(lengthEncoding: lengthEncoding)
            principalName = try buffer.read(lengthEncoding: lengthEncoding)
            issueTimestamp = try buffer.read()
            expiryTimestamp = try buffer.read()
            maxTimestamp = try buffer.read()
            tokenID = try buffer.read(lengthEncoding: lengthEncoding)
            hmac = try buffer.read(lengthEncoding: lengthEncoding)
            renewers = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 2 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
    
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
}