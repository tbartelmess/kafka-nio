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

import Foundation

struct PollError: Error {
    var errors: [Error]
}

enum KafkaError: Error, Equatable {
    case notEnoughBytes
    case invalidAPIKey
    case unsupportedAPIKey
    case invalidEnumValue
    case invalidCoordinatorType
    case responseBeforeRequest
    case invalidConsumerProtocolVersion
    case unsupportedConsumerProtocolVersion
    case unsupportedAssignmentProtocol
    case unknownNodeID
    case noKnownNode
    case invalidBootstrapAddress
    case rebalanceInProgress
    case crcValidationFailed
    case unexpectedKafkaErrorCode(ErrorCode)
    case assignmentDecodingError
    case invalidState
    case missingValue
    case missingMetadata
    case invalidCompressionAlgorithm
    case nodeForTopicNotFound
}

