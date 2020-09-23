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


struct FetchRequest: KafkaRequest { 
    struct FetchTopic: KafkaRequestStruct {
        struct FetchPartition: KafkaRequestStruct {
        
            
            /// The partition index.
            let partition: Int32    
            /// The current leader epoch of the partition.
            let currentLeaderEpoch: Int32?    
            /// The message offset.
            let fetchOffset: Int64    
            /// The earliest available offset of the follower replica.  The field is only used when the request is sent by the follower.
            let logStartOffset: Int64?    
            /// The maximum bytes to fetch from this partition.  See KIP-74 for cases where this limit may not be honored.
            let partitionMaxBytes: Int32
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                buffer.write(partition)
                if apiVersion >= 9 {
                    guard let currentLeaderEpoch = self.currentLeaderEpoch else {
                        throw KafkaError.missingValue
                    }
                    buffer.write(currentLeaderEpoch)
                }
                buffer.write(fetchOffset)
                if apiVersion >= 5 {
                    guard let logStartOffset = self.logStartOffset else {
                        throw KafkaError.missingValue
                    }
                    buffer.write(logStartOffset)
                }
                buffer.write(partitionMaxBytes)
        
            
            }
        }
    
        
        /// The name of the topic to fetch.
        let topic: String    
        /// The partitions to fetch.
        let partitions: [FetchPartition]
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            buffer.write(topic, lengthEncoding: lengthEncoding)
            try buffer.write(partitions, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    
        
        }
    }
    
    struct ForgottenTopic: KafkaRequestStruct {
    
        
        /// The partition name.
        let topic: String?    
        /// The partitions indexes to forget.
        let partitions: [Int32]?
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            if apiVersion >= 7 {
                guard let topic = self.topic else {
                    throw KafkaError.missingValue
                }
                buffer.write(topic, lengthEncoding: lengthEncoding)
            }
            if apiVersion >= 7 {
                guard let partitions = self.partitions else {
                    throw KafkaError.missingValue
                }
                buffer.write(partitions, lengthEncoding: lengthEncoding)
            }
    
        
        }
    }
    let apiKey: APIKey = .fetch
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The broker ID of the follower, of -1 if this request is from a consumer.
    let replicaID: Int32
    
    /// The maximum time in milliseconds to wait for the response.
    let maxWaitMs: Int32
    
    /// The minimum bytes to accumulate in the response.
    let minBytes: Int32
    
    /// The maximum bytes to fetch.  See KIP-74 for cases where this limit may not be honored.
    let maxBytes: Int32?
    
    /// This setting controls the visibility of transactional records. Using READ_UNCOMMITTED (isolation_level = 0) makes all records visible. With READ_COMMITTED (isolation_level = 1), non-transactional and COMMITTED transactional records are visible. To be more concrete, READ_COMMITTED returns all data from offsets smaller than the current LSO (last stable offset), and enables the inclusion of the list of aborted transactions in the result, which allows consumers to discard ABORTED transactional records
    let isolationLevel: IsolationLevel?
    
    /// The fetch session ID.
    let sessionID: Int32?
    
    /// The fetch session epoch, which is used for ordering requests in a session.
    let sessionEpoch: Int32?
    
    /// The topics to fetch.
    let topics: [FetchTopic]
    
    /// In an incremental fetch request, the partitions to remove.
    let forgottenTopicsData: [ForgottenTopic]?
    
    /// Rack ID of the consumer making this request
    let rackID: String?


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        buffer.write(replicaID)
        buffer.write(maxWaitMs)
        buffer.write(minBytes)
        if apiVersion >= 3 {
            guard let maxBytes = self.maxBytes else {
                throw KafkaError.missingValue
            }
            buffer.write(maxBytes)
        }
        if apiVersion >= 4 {
            guard let isolationLevel = self.isolationLevel else {
                throw KafkaError.missingValue
            }
            buffer.write(isolationLevel)
        }
        if apiVersion >= 7 {
            guard let sessionID = self.sessionID else {
                throw KafkaError.missingValue
            }
            buffer.write(sessionID)
        }
        if apiVersion >= 7 {
            guard let sessionEpoch = self.sessionEpoch else {
                throw KafkaError.missingValue
            }
            buffer.write(sessionEpoch)
        }
        try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 7 {
            guard let forgottenTopicsData = self.forgottenTopicsData else {
                throw KafkaError.missingValue
            }
            try buffer.write(forgottenTopicsData, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        if apiVersion >= 11 {
            guard let rackID = self.rackID else {
                throw KafkaError.missingValue
            }
            buffer.write(rackID, lengthEncoding: lengthEncoding)
        }
    }
}
