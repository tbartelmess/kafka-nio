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

import NIO

enum ErrorCode: UInt16, ProtocolEnum {
    case noError = 0
    case offsetOffsetOutOfRange = 1
    case corruptCorruptMessage = 2
    case unknownUnknownTopicOrPartition = 3
    case invalidInvalidFetchSize = 4
    case leaderLeaderNotAvailable = 5
    case notNotLeaderOrFollower = 6
    case requestRequestTimedOut = 7
    case brokerBrokerNotAvailable = 8
    case replicaReplicaNotAvailable = 9
    case messageMessageTooLarge = 10
    case staleStaleControllerEpoch = 11
    case offsetOffsetMetadataTooLarge = 12
    case networkNetworkException = 13
    case coordinatorCoordinatorLoadInProgress = 14
    case coordinatorCoordinatorNotAvailable = 15
    case notCoordinator = 16
    case invalidInvalidTopicException = 17
    case recordRecordListTooLarge = 18
    case notNotEnoughReplicas = 19
    case notNotEnoughReplicasAfterAppend = 20
    case invalidInvalidRequiredAcks = 21
    case illegalIllegalGeneration = 22
    case inconsistentInconsistentGroupProtocol = 23
    case invalidInvalidGroupId = 24
    case unknownMemberId = 25
    case invalidInvalidSessionTimeout = 26
    case rebalanceInProgress = 27
    case invalidInvalidCommitOffsetSize = 28
    case topicTopicAuthorizationFailed = 29
    case groupGroupAuthorizationFailed = 30
    case clusterClusterAuthorizationFailed = 31
    case invalidInvalidTimestamp = 32
    case unsupportedUnsupportedSaslMechanism = 33
    case illegalIllegalSaslState = 34
    case unsupportedUnsupportedVersion = 35
    case topicTopicAlreadyExists = 36
    case invalidInvalidPartitions = 37
    case invalidInvalidReplicationFactor = 38
    case invalidInvalidReplicaAssignment = 39
    case invalidInvalidConfig = 40
    case notNotController = 41
    case invalidInvalidRequest = 42
    case unsupportedUnsupportedForMessageFormat = 43
    case policyPolicyViolation = 44
    case outOutOfOrderSequenceNumber = 45
    case duplicateDuplicateSequenceNumber = 46
    case invalidInvalidProducerEpoch = 47
    case invalidInvalidTxnState = 48
    case invalidInvalidProducerIdMapping = 49
    case invalidInvalidTransactionTimeout = 50
    case concurrentConcurrentTransactions = 51
    case transactionTransactionCoordinatorFenced = 52
    case transactionalTransactionalIdAuthorizationFailed = 53
    case securitySecurityDisabled = 54
    case operationOperationNotAttempted = 55
    case kafkaKafkaStorageError = 56
    case logLogDirNotFound = 57
    case saslSaslAuthenticationFailed = 58
    case unknownUnknownProducerId = 59
    case reassignmentReassignmentInProgress = 60
    case delegationDelegationTokenAuthDisabled = 61
    case delegationDelegationTokenNotFound = 62
    case delegationDelegationTokenOwnerMismatch = 63
    case delegationDelegationTokenRequestNotAllowed = 64
    case delegationDelegationTokenAuthorizationFailed = 65
    case delegationDelegationTokenExpired = 66
    case invalidInvalidPrincipalType = 67
    case nonNonEmptyGroup = 68
    case groupGroupIdNotFound = 69
    case fetchFetchSessionIdNotFound = 70
    case invalidInvalidFetchSessionEpoch = 71
    case listenerListenerNotFound = 72
    case topicTopicDeletionDisabled = 73
    case fencedFencedLeaderEpoch = 74
    case unknownUnknownLeaderEpoch = 75
    case unsupportedUnsupportedCompressionType = 76
    case staleStaleBrokerEpoch = 77
    case offsetOffsetNotAvailable = 78
    case memberMemberIdRequired = 79
    case preferredPreferredLeaderNotAvailable = 80
    case groupGroupMaxSizeReached = 81
    case fencedFencedInstanceId = 82
    case eligibleEligibleLeadersNotAvailable = 83
    case electionElectionNotNeeded = 84
    case noNoReassignmentInProgress = 85
    case groupGroupSubscribedToTopic = 86
    case invalidInvalidRecord = 87
    case unstableUnstableOffsetCommit = 88


    static func readFrom(_ byteBuffer: inout ByteBuffer) throws -> ErrorCode {
        guard let value = byteBuffer.readInteger(endianness: .big, as: UInt16.self) else {
            throw KafkaError.notEnoughBytes
        }
        guard let errorCode = ErrorCode(rawValue: value) else {
            throw KafkaError.invalidEnumValue
        }
        return errorCode
    }
}
