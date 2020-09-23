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


struct ListGroupsRequest: KafkaRequest { 
    
    let apiKey: APIKey = .listGroups
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The states of the groups we want to list. If empty all groups are returned with their state.
    let statesFilter: [String]?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 3) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        if apiVersion >= 4 {
            guard let statesFilter = self.statesFilter else {
                throw KafkaError.missingValue
            }
            buffer.write(statesFilter, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 3 {
            buffer.write(taggedFields)
        }
    }
}
