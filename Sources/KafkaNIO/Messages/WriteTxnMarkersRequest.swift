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


struct WriteTxnMarkersRequest: KafkaRequest { 
    struct WritableTxnMarker: KafkaRequestStruct {
        struct WritableTxnMarkerTopic: KafkaRequestStruct {
        
            
            /// The topic name.
            let name: String    
            /// The indexes of the partitions to write transaction markers for.
            let partitionIndexes: [Int32]
            func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = .bigEndian
                buffer.write(name, lengthEncoding: lengthEncoding)
                buffer.write(partitionIndexes, lengthEncoding: lengthEncoding)
        
            }
        
            init(name: String, partitionIndexes: [Int32]) {
                self.name = name
                self.partitionIndexes = partitionIndexes
            }
        
        }
    
        
        /// The current producer ID.
        let producerID: Int64    
        /// The current epoch associated with the producer ID.
        let producerEpoch: Int16    
        /// The result of the transaction to write to the partitions (false = ABORT, true = COMMIT).
        let transactionResult: Bool    
        /// Each topic that we want to write transaction marker(s) for.
        let topics: [WritableTxnMarkerTopic]    
        /// Epoch associated with the transaction state partition hosted by this transaction coordinator
        let coordinatorEpoch: Int32
        func write(into buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            buffer.write(producerID)
            buffer.write(producerEpoch)
            buffer.write(transactionResult)
            try buffer.write(topics, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
            buffer.write(coordinatorEpoch)
    
        }
    
        init(producerID: Int64, producerEpoch: Int16, transactionResult: Bool, topics: [WritableTxnMarkerTopic], coordinatorEpoch: Int32) {
            self.producerID = producerID
            self.producerEpoch = producerEpoch
            self.transactionResult = transactionResult
            self.topics = topics
            self.coordinatorEpoch = coordinatorEpoch
        }
    
    }
    
    let apiKey: APIKey = .writeTxnMarkers
    let apiVersion: APIVersion
    let clientID: String?
    let correlationID: Int32
    
    /// The transaction markers to be written.
    let markers: [WritableTxnMarker]


    func write(into buffer: inout ByteBuffer) throws {
        let lengthEncoding: IntegerEncoding = .bigEndian
        writeHeader(into: &buffer, version: apiKey.requestHeaderVersion(for: apiVersion))
        try buffer.write(markers, apiVersion: apiVersion, lengthEncoding: lengthEncoding)
    }
}
