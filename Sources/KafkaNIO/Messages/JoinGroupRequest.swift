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


struct JoinGroupRequest: KafkaRequest { 
    struct JoinGroupRequestProtocol: KafkaRequestStruct {
    
        
        /// The protocol name.
        let name: String    
        /// The protocol metadata.
        let metadata: [UInt8]
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 6) ? .varint : .bigEndian
            buffer.write(name, lengthEncoding: lengthEncoding)
            buffer.write(metadata, lengthEncoding: lengthEncoding)
            if apiVersion >= 6 {
                buffer.write(taggedFields)
            }
        
        }
    }
    let apiKey: APIKey = .joinGroup
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The group identifier.
    let groupID: String
    
    /// The coordinator considers the consumer dead if it receives no heartbeat after this timeout in milliseconds.
    let sessionTimeoutMs: Int32
    
    /// The maximum time in milliseconds that the coordinator will wait for each member to rejoin when rebalancing the group.
    let rebalanceTimeoutMs: Int32?
    
    /// The member id assigned by the group coordinator.
    let memberID: String
    
    /// The unique identifier of the consumer instance provided by end user.
    let groupInstanceID: String?
    
    /// The unique name the for class of protocols implemented by the group we want to join.
    let protocolType: String
    
    /// The list of protocols that the member supports.
    let protocols: [JoinGroupRequestProtocol]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 6) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(groupID, lengthEncoding: lengthEncoding)
        buffer.write(sessionTimeoutMs)
        if apiVersion >= 1 {
            guard let rebalanceTimeoutMs = self.rebalanceTimeoutMs else {
                throw KafkaError.missingValue
            }
            buffer.write(rebalanceTimeoutMs)
        }
        buffer.write(memberID, lengthEncoding: lengthEncoding)
        if apiVersion >= 5 {
            buffer.write(groupInstanceID, lengthEncoding: lengthEncoding)
        }
        buffer.write(protocolType, lengthEncoding: lengthEncoding)
        try buffer.write(protocols, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 6 {
            buffer.write(taggedFields)
        }
    }
}
