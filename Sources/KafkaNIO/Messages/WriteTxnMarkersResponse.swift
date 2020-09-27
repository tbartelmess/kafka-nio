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
    init(apiVersion: APIVersion, producerID: Int64, topics: [WritableTxnMarkerTopicResult]) {
        self.apiVersion = apiVersion
        self.producerID = producerID
        self.topics = topics
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


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, markers: [WritableTxnMarkerResult]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.markers = markers
    }
}