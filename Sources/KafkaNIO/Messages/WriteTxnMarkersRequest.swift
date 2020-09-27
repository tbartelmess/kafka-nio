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
    init(apiVersion: APIVersion, producerID: Int64, producerEpoch: Int16, transactionResult: Bool, topics: [WritableTxnMarkerTopic], coordinatorEpoch: Int32) {
        self.apiVersion = apiVersion
        self.producerID = producerID
        self.producerEpoch = producerEpoch
        self.transactionResult = transactionResult
        self.topics = topics
        self.coordinatorEpoch = coordinatorEpoch
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
