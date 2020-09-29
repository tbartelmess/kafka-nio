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


struct UpdateMetadataResponse: KafkaResponse { 
    
    let apiKey: APIKey = .updateMetadata
    let apiVersion: APIVersion
    let responseHeader: KafkaResponseHeader
    
    /// The error code, or 0 if there was no error.
    let errorCode: ErrorCode
    let taggedFields: [TaggedField]


    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws { 
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        errorCode = try buffer.read()
        if apiVersion >= 6 {
            taggedFields = try buffer.read()
        } else {
            taggedFields = []
        }
    }


    init(apiVersion: APIVersion, responseHeader: KafkaResponseHeader, errorCode: ErrorCode) {
        self.apiVersion = apiVersion
        self.responseHeader = responseHeader
        self.taggedFields = []
        self.errorCode = errorCode
    }
}