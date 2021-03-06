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


struct HeartbeatRequest: KafkaRequest { 
    
    let apiKey: APIKey = .heartbeat
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The group id.
    let groupID: String
    
    /// The generation of the group.
    let generationID: Int32
    
    /// The member ID.
    let memberID: String
    
    /// The unique identifier of the consumer instance provided by end user.
    let groupInstanceID: String?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 4) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(groupID, lengthEncoding: lengthEncoding)
        buffer.write(generationID)
        buffer.write(memberID, lengthEncoding: lengthEncoding)
        if apiVersion >= 3 {
            buffer.write(groupInstanceID, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 4 {
            buffer.write(taggedFields)
        }
    }
}
