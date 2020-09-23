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


struct ApiVersionsRequest: KafkaRequest { 
    
    let apiKey: APIKey = .apiVersions
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The name of the client.
    let clientSoftwareName: String?
    
    /// The version of the client.
    let clientSoftwareVersion: String?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = (apiVersion >= 3) ? .varint : .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        if apiVersion >= 3 {
            guard let clientSoftwareName = self.clientSoftwareName else {
                throw KafkaError.missingValue
            }
            buffer.write(clientSoftwareName, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 3 {
            guard let clientSoftwareVersion = self.clientSoftwareVersion else {
                throw KafkaError.missingValue
            }
            buffer.write(clientSoftwareVersion, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 3 {
            buffer.write(taggedFields)
        }
    }
}
