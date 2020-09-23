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


struct CreateDelegationTokenRequest: KafkaRequest { 
    struct CreatableRenewers: KafkaRequestStruct {
    
        
        /// The type of the Kafka principal.
        let principalType: String    
        /// The name of the Kafka principal.
        let principalName: String
        let taggedFields: [TaggedField] = []
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
            buffer.write(principalType, lengthEncoding: lengthEncoding)
            buffer.write(principalName, lengthEncoding: lengthEncoding)
            if apiVersion >= 2 {
                buffer.write(taggedFields)
            }
        
        }
    }
    let apiKey: APIKey = .createDelegationToken
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// A list of those who are allowed to renew this token before it expires.
    let renewers: [CreatableRenewers]
    
    /// The maximum lifetime of the token in milliseconds, or -1 to use the server side default.
    let maxLifetimeMs: Int64


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(renewers, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        buffer.write(maxLifetimeMs)
        if apiVersion >= 2 {
            buffer.write(taggedFields)
        }
    }
}
