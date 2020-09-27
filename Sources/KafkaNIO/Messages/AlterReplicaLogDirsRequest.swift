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
    struct AlterReplicaLogDir: KafkaRequestStruct {
        struct AlterReplicaLogDirTopic: KafkaRequestStruct {
        
            
            /// The topic name.
            let name: String    
            /// The partition indexes.
            let partitions: [Int32]
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = .bigEndian
                buffer.write(name, lengthEncoding: lengthEncoding)
                buffer.write(partitions, lengthEncoding: lengthEncoding)
        
            }
        
            init(name: String, partitions: [Int32]) {
                self.name = name
                self.partitions = partitions
            }
        
        }
    
        
        /// The absolute directory path.
        let path: String    
        /// The topics to add to the directory.
        let topics: [AlterReplicaLogDirTopic]
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            buffer.write(path, lengthEncoding: lengthEncoding)
            try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    
        }
    
        init(path: String, topics: [AlterReplicaLogDirTopic]) {
            self.path = path
            self.topics = topics
        }
    
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
