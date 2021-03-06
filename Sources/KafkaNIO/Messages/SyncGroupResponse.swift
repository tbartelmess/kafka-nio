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


struct SyncGroupResponse: KafkaResponse { 
    
    let apiKey: APIKey = .syncGroup
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// The error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// The group protocol type.
    let protocolType: String?
    
    /// The group protocol name.
    let protocolName: String?
    
    /// The member assignment.
    let assignment: [UInt8]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 4) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        if apiVersion >= 1 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
        errorCode = try buffer.read()
        if apiVersion >= 5 {
            protocolType = try buffer.read(lengthEncoding: lengthEncoding)
        } else { 
            protocolType = nil
        }
        if apiVersion >= 5 {
            protocolName = try buffer.read(lengthEncoding: lengthEncoding)
        } else { 
            protocolName = nil
        }
        assignment = try buffer.read(lengthEncoding: lengthEncoding)
        if apiVersion >= 4 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32?, errorCode: ErrorCode, protocolType: String?, protocolName: String?, assignment: [UInt8]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.errorCode = errorCode
        self.protocolType = protocolType
        self.protocolName = protocolName
        self.assignment = assignment
    }
}