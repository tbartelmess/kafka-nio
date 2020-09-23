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


struct DescribeGroupsResponse: KafkaResponse { 
    struct DescribedGroup: KafkaResponseStruct {
        struct DescribedGroupMember: KafkaResponseStruct {
        
            
            /// The member ID assigned by the group coordinator.
            let memberID: String    
            /// The unique identifier of the consumer instance provided by end user.
            let groupInstanceID: String?    
            /// The client ID used in the member's latest join group request.
            let clientID: String    
            /// The client host.
            let clientHost: String    
            /// The metadata corresponding to the current group protocol in use.
            let memberMetadata: [UInt8]    
            /// The current assignment provided by the group leader.
            let memberAssignment: [UInt8]
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = (apiVersion >= 5) ? .varint : .bigEndian
                memberID = try buffer.read(lengthEncoding: lengthEncoding)
                if apiVersion >= 4 {
                    groupInstanceID = try buffer.read(lengthEncoding: lengthEncoding)
                } else { 
                    groupInstanceID = nil
                }
                clientID = try buffer.read(lengthEncoding: lengthEncoding)
                clientHost = try buffer.read(lengthEncoding: lengthEncoding)
                memberMetadata = try buffer.read(lengthEncoding: lengthEncoding)
                memberAssignment = try buffer.read(lengthEncoding: lengthEncoding)
                if apiVersion >= 5 {
                    let _ : [TaggedField] = try buffer.read()
                }
            }
        
        }
    
        
        /// The describe error, or 0 if there was no error.
        let errorCode: ErrorCode    
        /// The group ID string.
        let groupID: String    
        /// The group state string, or the empty string.
        let groupState: String    
        /// The group protocol type, or the empty string.
        let protocolType: String    
        /// The group protocol data, or the empty string.
        let protocolData: String    
        /// The group members.
        let members: [DescribedGroupMember]    
        /// 32-bit bitfield to represent authorized operations for this group.
        let authorizedOperations: Int32?
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 5) ? .varint : .bigEndian
            errorCode = try buffer.read()
            groupID = try buffer.read(lengthEncoding: lengthEncoding)
            groupState = try buffer.read(lengthEncoding: lengthEncoding)
            protocolType = try buffer.read(lengthEncoding: lengthEncoding)
            protocolData = try buffer.read(lengthEncoding: lengthEncoding)
            members = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            if apiVersion >= 3 {
                authorizedOperations = try buffer.read()
            } else { 
                authorizedOperations = nil
            }
            if apiVersion >= 5 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
    
    }
    let apiKey: APIKey = .describeGroups
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// Each described group.
    let groups: [DescribedGroup]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 5) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        if apiVersion >= 1 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
        groups = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 5 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }
}