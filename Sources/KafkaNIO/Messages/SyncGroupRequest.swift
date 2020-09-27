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


struct SyncGroupRequest: KafkaRequest { 
    struct SyncGroupRequestAssignment: KafkaRequestStruct {
    
        
        /// The ID of the member to assign.
        let memberID: String    
        /// The member assignment.
        let assignment: [UInt8]
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 4) ? .varint : .bigEndian
            buffer.write(memberID, lengthEncoding: lengthEncoding)
            buffer.write(assignment, lengthEncoding: lengthEncoding)
            if apiVersion >= 4 {
                buffer.write(taggedFields)
            }
        }
    
        init(memberID: String, assignment: [UInt8]) {
            self.memberID = memberID
            self.assignment = assignment
        }
    
    }
    
    let apiKey: APIKey = .syncGroup
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The unique group identifier.
    let groupID: String
    
    /// The generation of the group.
    let generationID: Int32
    
    /// The member ID assigned by the group.
    let memberID: String
    
    /// The unique identifier of the consumer instance provided by end user.
    let groupInstanceID: String?
    
    /// The group protocol type.
    let protocolType: String?
    
    /// The group protocol name.
    let protocolName: String?
    
    /// Each assignment.
    let assignments: [SyncGroupRequestAssignment]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 4) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(groupID, lengthEncoding: lengthEncoding)
        buffer.write(generationID)
        buffer.write(memberID, lengthEncoding: lengthEncoding)
        if apiVersion >= 3 {
            buffer.write(groupInstanceID, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 5 {
            buffer.write(protocolType, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 5 {
            buffer.write(protocolName, lengthEncoding: lengthEncoding)
        }
        try buffer.write(assignments, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 4 {
            buffer.write(taggedFields)
        }
    }
}
