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


struct WriteTxnMarkersResponse: KafkaResponse { 
    struct WritableTxnMarkerResult: KafkaResponseStruct {
        struct WritableTxnMarkerTopicResult: KafkaResponseStruct {
            struct WritableTxnMarkerPartitionResult: KafkaResponseStruct {
            
                
                /// The partition index.
                let partitionIndex: Int32    
                /// The error code, or 0 if there was no error.
                let errorCode: ErrorCode
                init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                    partitionIndex = try buffer.read()
                    errorCode = try buffer.read()
                }
            
            }
        
            
            /// The topic name.
            let name: String    
            /// The results by partition.
            let partitions: [WritableTxnMarkerPartitionResult]
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = .bigEndian
                name = try buffer.read(lengthEncoding: lengthEncoding)
                partitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            }
        
        }
    
        
        /// The current producer ID in use by the transactional ID.
        let producerID: Int64    
        /// The results by topic.
        let topics: [WritableTxnMarkerTopicResult]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            producerID = try buffer.read()
            topics = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
    
    }
    let apiKey: APIKey = .writeTxnMarkers
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The results for writing makers.
    let markers: [WritableTxnMarkerResult]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        markers = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }
}