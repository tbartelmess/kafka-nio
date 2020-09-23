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


struct ListGroupsResponse: KafkaResponse { 
    struct ListedGroup: KafkaResponseStruct {
    
        
        /// The group ID.
        let groupID: String    
        /// The group protocol type.
        let protocolType: String    
        /// The group state name.
        let groupState: String?
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 3) ? .varint : .bigEndian
            groupID = try buffer.read(lengthEncoding: lengthEncoding)
            protocolType = try buffer.read(lengthEncoding: lengthEncoding)
            if apiVersion >= 4 {
                groupState = try buffer.read(lengthEncoding: lengthEncoding)
            } else { 
                groupState = nil
            }
            if apiVersion >= 3 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
    
    }
    let apiKey: APIKey = .listGroups
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// The error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// Each group in the response.
    let groups: [ListedGroup]
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
        groups = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 3 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }
}