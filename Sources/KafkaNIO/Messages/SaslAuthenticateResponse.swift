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


struct SaslAuthenticateResponse: KafkaResponse { 
    
    let apiKey: APIKey = .saslAuthenticate
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// The error message, or null if there was no error.
    let errorMessage: String?
    
    /// The SASL authentication bytes from the server, as defined by the SASL mechanism.
    let authBytes: [UInt8]
    
    /// The SASL authentication bytes from the server, as defined by the SASL mechanism.
    let sessionLifetimeMs: Int64?
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        errorCode = try buffer.read()
        errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
        authBytes = try buffer.read(lengthEncoding: lengthEncoding)
        if apiVersion >= 1 {
            sessionLifetimeMs = try buffer.read()
        } else { 
            sessionLifetimeMs = nil
        }
        if apiVersion >= 2 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }
}