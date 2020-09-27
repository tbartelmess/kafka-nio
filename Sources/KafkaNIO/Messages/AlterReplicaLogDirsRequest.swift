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


struct AlterReplicaLogDirsRequest: KafkaRequest { 
    init(apiVersion: APIVersion, path: String, topics: [AlterReplicaLogDirTopic]) {
        self.apiVersion = apiVersion
        self.path = path
        self.topics = topics
    }
    let apiKey: APIKey = .alterReplicaLogDirs
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The alterations to make for each directory.
    let dirs: [AlterReplicaLogDir]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(dirs, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }
}
