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


struct ControlledShutdownRequest: KafkaRequest { 
    
    let apiKey: APIKey = .controlledShutdown
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    let taggedFields: [TaggedField] = []
    
    /// The id of the broker for which controlled shutdown has been requested.
    let brokerID: Int32
    
    /// The broker epoch.
    let brokerEpoch: Int64?


    func write(into buffer: inout ByteBuffer) throws {
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(brokerID)
        if apiVersion >= 2 {
            guard let brokerEpoch = self.brokerEpoch else {
                throw KafkaError.missingValue
            }
            buffer.write(brokerEpoch)
        }
        if apiVersion >= 3 {
            buffer.write(taggedFields)
        }
    }
}
