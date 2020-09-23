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


struct DeleteTopicsRequest: KafkaRequest { 
    
    let apiKey: APIKey = .deleteTopics
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The names of the topics to delete
    let topicNames: [String]
    
    /// The length of time in milliseconds to wait for the deletions to complete.
    let timeoutMs: Int32


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 4) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(topicNames, lengthEncoding: lengthEncoding)
        buffer.write(timeoutMs)
        if apiVersion >= 4 {
            buffer.write(taggedFields)
        }
    }
}
