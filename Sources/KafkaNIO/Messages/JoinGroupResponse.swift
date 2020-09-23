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


struct JoinGroupResponse: KafkaResponse { 
    struct JoinGroupResponseMember: KafkaResponseStruct {
    
        
        /// The group member ID.
        let memberID: String    
        /// The unique identifier of the consumer instance provided by end user.
        let groupInstanceID: String?    
        /// The group member metadata.
        let metadata: [UInt8]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 6) ? .varint : .bigEndian
            memberID = try buffer.read(lengthEncoding: lengthEncoding)
            if apiVersion >= 5 {
                groupInstanceID = try buffer.read(lengthEncoding: lengthEncoding)
            } else { 
                groupInstanceID = nil
            }
            metadata = try buffer.read(lengthEncoding: lengthEncoding)
            if apiVersion >= 6 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
    
    }
    let apiKey: APIKey = .joinGroup
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// The error code, or 0 if there was no error.
    let errorCode: ErrorCode
    
    /// The generation ID of the group.
    let generationID: Int32
    
    /// The group protocol name.
    let protocolType: String?
    
    /// The group protocol selected by the coordinator.
    let protocolName: String?
    
    /// The leader of the group.
    let leader: String
    
    /// The member ID assigned by the group coordinator.
    let memberID: String
    
    /// None
    let members: [JoinGroupResponseMember]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 6) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        if apiVersion >= 2 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
        errorCode = try buffer.read()
        generationID = try buffer.read()
        if apiVersion >= 7 {
            protocolType = try buffer.read(lengthEncoding: lengthEncoding)
        } else { 
            protocolType = nil
        }
        protocolName = try buffer.read(lengthEncoding: lengthEncoding)
        leader = try buffer.read(lengthEncoding: lengthEncoding)
        memberID = try buffer.read(lengthEncoding: lengthEncoding)
        members = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 6 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }
}