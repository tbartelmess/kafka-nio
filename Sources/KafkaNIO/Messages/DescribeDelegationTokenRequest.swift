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


struct DescribeDelegationTokenRequest: KafkaRequest { 
    struct DescribeDelegationTokenOwner: KafkaRequestStruct {
    
        
        /// The owner principal type.
        let principalType: String    
        /// The owner principal name.
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
    let apiKey: APIKey = .describeDelegationToken
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// Each owner that we want to describe delegation tokens for, or null to describe all tokens.
    let owners: [DescribeDelegationTokenOwner]?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 2) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(owners, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 2 {
            buffer.write(taggedFields)
        }
    }
}
