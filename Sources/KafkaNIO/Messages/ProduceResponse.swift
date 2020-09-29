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


struct ProduceResponse: KafkaResponse { 
    struct TopicProduceResponse: KafkaResponseStruct {
        struct PartitionProduceResponse: KafkaResponseStruct {
            struct BatchIndexAndErrorMessage: KafkaResponseStruct {
            
                
                /// The batch index of the record that cause the batch to be dropped
                let batchIndex: Int32?    
                /// The error message of the record that caused the batch to be dropped
                let batchIndexErrorMessage: String?
                init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                    let lengthEncoding: IntegerEncoding = .bigEndian
                    if apiVersion >= 8 {
                        batchIndex = try buffer.read()
                    } else { 
                        batchIndex = nil
                    }
                    if apiVersion >= 8 {
                        batchIndexErrorMessage = try buffer.read(lengthEncoding: lengthEncoding)
                    } else { 
                        batchIndexErrorMessage = nil
                    }
                }
                init(batchIndex: Int32?, batchIndexErrorMessage: String?) {
                    self.batchIndex = batchIndex
                    self.batchIndexErrorMessage = batchIndexErrorMessage
                }
            
            }
        
            
            /// The partition index.
            let partitionIndex: Int32    
            /// The error code, or 0 if there was no error.
            let errorCode: ErrorCode    
            /// The base offset.
            let baseOffset: Int64    
            /// The timestamp returned by broker after appending the messages. If CreateTime is used for the topic, the timestamp will be -1.  If LogAppendTime is used for the topic, the timestamp will be the broker local time when the messages are appended.
            let logAppendTimeMs: Int64?    
            /// The log start offset.
            let logStartOffset: Int64?    
            /// The batch indices of records that caused the batch to be dropped
            let recordErrors: [BatchIndexAndErrorMessage]?    
            /// The global error message summarizing the common root cause of the records that caused the batch to be dropped
            let errorMessage: String?
            init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
                let lengthEncoding: IntegerEncoding = .bigEndian
                partitionIndex = try buffer.read()
                errorCode = try buffer.read()
                baseOffset = try buffer.read()
                if apiVersion >= 2 {
                    logAppendTimeMs = try buffer.read()
                } else { 
                    logAppendTimeMs = nil
                }
                if apiVersion >= 5 {
                    logStartOffset = try buffer.read()
                } else { 
                    logStartOffset = nil
                }
                if apiVersion >= 8 {
                    recordErrors = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
                } else { 
                    recordErrors = nil
                }
                if apiVersion >= 8 {
                    errorMessage = try buffer.read(lengthEncoding: lengthEncoding)
                } else { 
                    errorMessage = nil
                }
            }
            init(partitionIndex: Int32, errorCode: ErrorCode, baseOffset: Int64, logAppendTimeMs: Int64?, logStartOffset: Int64?, recordErrors: [BatchIndexAndErrorMessage]?, errorMessage: String?) {
                self.partitionIndex = partitionIndex
                self.errorCode = errorCode
                self.baseOffset = baseOffset
                self.logAppendTimeMs = logAppendTimeMs
                self.logStartOffset = logStartOffset
                self.recordErrors = recordErrors
                self.errorMessage = errorMessage
            }
        
        }
    
        
        /// The topic name
        let name: String    
        /// Each partition that we produced to within the topic.
        let partitions: [PartitionProduceResponse]
        init(from buffer: inout ByteBuffer, apiVersion: APIVersion) throws {
            let lengthEncoding: IntegerEncoding = .bigEndian
            name = try buffer.read(lengthEncoding: lengthEncoding)
            partitions = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        }
        init(name: String, partitions: [PartitionProduceResponse]) {
            self.name = name
            self.partitions = partitions
        }
    
    }
    
    let apiKey: APIKey = .produce
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// Each produce response
    let responses: [TopicProduceResponse]
    
    /// The duration in milliseconds for which the request was throttled due to a quota violation, or zero if the request did not violate any quota.
    let throttleTimeMs: Int32?


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        let lengthEncoding: IntegerEncoding = .bigEndian
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        responses = try buffer.read(apiVersion: apiVersion, lengthEncoding: lengthEncoding)
        if apiVersion >= 1 {
            throttleTimeMs = try buffer.read()
        } else { 
            throttleTimeMs = nil
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, responses: [TopicProduceResponse], throttleTimeMs: Int32?) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.responses = responses
        self.throttleTimeMs = throttleTimeMs
    }
}