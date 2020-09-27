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


struct LeaveGroupResponse: KafkaResponse { 
    struct MemberResponse: KafkaResponseStruct {
    
        
        /// The member ID to remove from the group.
        let memberID: String?    
        /// The group instance ID to remove from the group.
        let groupInstanceID: String?    
        /// The error code, or 0 if there was no error.
        let errorCode: ErrorCode?
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 4) ? .varint : .bigEndian
            if apiVersion >= 3 {
                memberID = try buffer.read(lengthEncoding: lengthEncoding)
            } else { 
                memberID = nil
            }
            if apiVersion >= 3 {
                groupInstanceID = try buffer.read(lengthEncoding: lengthEncoding)
            } else { 
                groupInstanceID = nil
            }
            if apiVersion >= 3 {
                errorCode = try buffer.read()
            } else { 
                errorCode = nil
            }
            if apiVersion >= 4 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(memberID: String?, groupInstanceID: String?, errorCode: ErrorCode?) {
            self.memberID = memberID
            self.groupInstanceID = groupInstanceID
            self.errorCode = errorCode
        }
    
    }
    
    let apiKey: APIKey = .leaveGroup
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// The error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// List of leaving member responses.
    let members: [MemberResponse]?
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
        if apiVersion >= 3 {
            members = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        } else { 
            members = nil
        }
        if apiVersion >= 4 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, throttleTimeMs: Int32?, errorCode: ErrorCode, members: [MemberResponse]?) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.throttleTimeMs = throttleTimeMs
        self.errorCode = errorCode
        self.members = members
    }
}