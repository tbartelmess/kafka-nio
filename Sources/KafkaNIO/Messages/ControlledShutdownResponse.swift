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


struct ControlledShutdownResponse: KafkaResponse { 
    struct RemainingPartition: KafkaResponseStruct {
    
        
        /// The name of the topic.
        let topicName: String    
        /// The index of the partition.
        let partitionIndex: Int32
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = (apiVersion >= 3) ? .varint : .bigEndian
            topicName = try buffer.read(lengthEncoding: lengthEncoding)
            partitionIndex = try buffer.read()
            if apiVersion >= 3 {
                let _ : [TaggedField] = try buffer.read()
            }
        }
        init(topicName: String, partitionIndex: Int32) {
            self.topicName = topicName
            self.partitionIndex = partitionIndex
        }
    
    }
    
    let apiKey: APIKey = .controlledShutdown
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The top-level error code.
    let errorCode: ErrorCode
    
    /// The partitions that the broker still leads.
    let remainingPartitions: [RemainingPartition]
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = (apiVersion >= 3) ? .varint : .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        errorCode = try buffer.read()
        remainingPartitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 3 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, errorCode: ErrorCode, remainingPartitions: [RemainingPartition]) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.errorCode = errorCode
        self.remainingPartitions = remainingPartitions
    }
}