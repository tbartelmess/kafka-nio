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


struct DescribeGroupsRequest: KafkaRequest { 
    
    let apiKey: APIKey = .describeGroups
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The names of the groups to describe
    let groups: [String]
    
    /// Whether to include authorized operations.
    let includeAuthorizedOperations: Bool?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 5) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(groups, lengthEncoding: lengthEncoding)
        if apiVersion >= 3 {
            guard let includeAuthorizedOperations = self.includeAuthorizedOperations else {
                throw KafkaError.missingValue
            }
            buffer.write(includeAuthorizedOperations)
        }
        if apiVersion >= 5 {
            buffer.write(taggedFields)
        }
    }
}
