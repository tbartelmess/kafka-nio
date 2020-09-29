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


struct FindCoordinatorResponse: KafkaResponse { 
    
    let apiKey: APIKey = .findCoordinator
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// The error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// The error message, or null if there was no error.
    let errorMessage: String?
    
    /// The node id.
    let nodeID: Int32
    
    /// The host name.
    let host: String
    
    /// The port.
    let port: Int32
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 3) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        if apiVersion >= 1 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
        errorCode = try buffer.read()
        if apiVersion >= 1 {
            errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
        } else { 
            errorMessage = nil
        }
        nodeID = try buffer.read()
        host = try buffer.read(lengthEncoding: lengthEncoding)
        port = try buffer.read()
        if apiVersion >= 3 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32?, errorCode: ErrorCode, errorMessage: String?, nodeID: Int32, host: String, port: Int32) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.nodeID = nodeID
        self.host = host
        self.port = port
    }
}