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


struct OffsetForLeaderEpochRequest: KafkaRequest { 
    struct OffsetForLeaderTopic: KafkaRequestStruct {
        struct OffsetForLeaderPartition: KafkaRequestStruct {
        
            
            /// The partition index.
            let partitionIndex: Int32    
            /// An epoch used to fence consumers/replicas with old metadata.  If the epoch provided by the client is larger than the current epoch known to the broker, then the UNKNOWN_LEADER_EPOCH error code will be returned. If the provided epoch is smaller, then the FENCED_LEADER_EPOCH error code will be returned.
            let currentLeaderEpoch: Int32?    
            /// The epoch to look up an offset for.
            let leaderEpoch: Int32
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                buffer.write(partitionIndex)
                if apiVersion >= 2 {
                    guard let currentLeaderEpoch = self.currentLeaderEpoch else {
                        throw KafkaError.missingValue
                    }
                    buffer.write(currentLeaderEpoch)
                }
                buffer.write(leaderEpoch)
        
            
            }
        }
    
        
        /// The topic name.
        let name: String    
        /// Each partition to get offsets for.
        let partitions: [OffsetForLeaderPartition]
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            buffer.write(name, lengthEncoding: lengthEncoding)
            try buffer.write(partitions, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    
        
        }
    }
    let apiKey: APIKey = .offsetForLeaderEpoch
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The broker ID of the follower, of -1 if this request is from a consumer.
    let replicaID: Int32?
    
    /// Each topic to get offsets for.
    let topics: [OffsetForLeaderTopic]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        if apiVersion >= 3 {
            guard let replicaID = self.replicaID else {
                throw KafkaError.missingValue
            }
            buffer.write(replicaID)
        }
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }
}
