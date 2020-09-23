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


struct LeaveGroupRequest: KafkaRequest { 
    struct MemberIdentity: KafkaRequestStruct {
    
        
        /// The member ID to remove from the group.
        let memberID: String?    
        /// The group instance ID to remove from the group.
        let groupInstanceID: String?
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 4) ? .varint : .bigEndian
            if apiVersion >= 3 {
                guard let memberID = self.memberID else {
                    throw KafkaError.missingValue
                }
                buffer.write(memberID, lengthEncoding: lengthEncoding)
            }
            if apiVersion >= 3 {
                buffer.write(groupInstanceID, lengthEncoding: lengthEncoding)
            }
            if apiVersion >= 4 {
                buffer.write(taggedFields)
            }
        
        }
    }
    let apiKey: APIKey = .leaveGroup
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The ID of the group to leave.
    let groupID: String
    
    /// The member ID to remove from the group.
    let memberID: String?
    
    /// List of leaving member identities.
    let members: [MemberIdentity]?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 4) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(groupID, lengthEncoding: lengthEncoding)
        if apiVersion <= 2 {
            guard let memberID = self.memberID else {
                throw KafkaError.missingValue
            }
            buffer.write(memberID, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 3 {
            guard let members = self.members else {
                throw KafkaError.missingValue
            }
            try buffer.write(members, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 4 {
            buffer.write(taggedFields)
        }
    }
}
