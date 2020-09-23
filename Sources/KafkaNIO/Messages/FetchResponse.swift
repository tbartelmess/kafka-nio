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


struct FetchResponse: KafkaResponse { 
    struct FetchableTopicResponse: KafkaResponseStruct {
        struct FetchablePartitionResponse: KafkaResponseStruct {
            struct AbortedTransaction: KafkaResponseStruct {
            
                
                /// The producer id associated with the aborted transaction.
                let producerID: Int64?    
                /// The first offset in the aborted transaction.
                let firstOffset: Int64?
                init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                    if apiVersion >= 4 {
                        producerID = try buffer.read()
                    } else { 
                        producerID = nil
                    }
                    if apiVersion >= 4 {
                        firstOffset = try buffer.read()
                    } else { 
                        firstOffset = nil
                    }
                }
            
            }
        
            
            /// The partition index.
            let partition: Int32    
            /// The error code, or 0 if there was no fetch error.
            let errorCode: ErrorCode    
            /// The current high water mark.
            let highWatermark: Int64    
            /// The last stable offset (or LSO) of the partition. This is the last offset such that the state of all transactional records prior to this offset have been decided (ABORTED or COMMITTED)
            let lastStableOffset: Int64?    
            /// The current log start offset.
            let logStartOffset: Int64?    
            /// The aborted transactions.
            let abortedTransactions: [AbortedTransaction]?    
            /// The preferred read replica for the consumer to use on its next fetch request
            let preferredReadReplica: Int32?    
            /// The record data.
            let recordSet: ByteBuffer?
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = .bigEndian
                partition = try buffer.read()
                errorCode = try buffer.read()
                highWatermark = try buffer.read()
                if apiVersion >= 4 {
                    lastStableOffset = try buffer.read()
                } else { 
                    lastStableOffset = nil
                }
                if apiVersion >= 5 {
                    logStartOffset = try buffer.read()
                } else { 
                    logStartOffset = nil
                }
                if apiVersion >= 4 {
                    abortedTransactions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
                } else { 
                    abortedTransactions = nil
                }
                if apiVersion >= 11 {
                    preferredReadReplica = try buffer.read()
                } else { 
                    preferredReadReplica = nil
                }
                recordSet = try buffer.read()
            }
        
        }
    
        
        /// The topic name.
        let topic: String    
        /// The topic partitions.
        let partitionResponses: [FetchablePartitionResponse]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            topic = try buffer.read(lengthEncoding: lengthEncoding)
            partitionResponses = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
    
    }
    let apiKey: APIKey = .fetch
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?
    
    /// The top level response error code.
    let errorCode: ErrorCode?
    
    /// The fetch session ID, or 0 if this is not part of a fetch session.
    let sessionID: Int32?
    
    /// The response topics.
    let responses: [FetchableTopicResponse]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        if apiVersion >= 1 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
        if apiVersion >= 7 {
            errorCode = try buffer.read()
        } else { 
            errorCode = nil
        }
        if apiVersion >= 7 {
            sessionID = try buffer.read()
        } else { 
            sessionID = nil
        }
        responses = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }
}