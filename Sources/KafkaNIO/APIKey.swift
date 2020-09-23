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
typealias APIVersion = Int16

enum APIKey: UInt16, Codable, CaseIterable, ProtocolEnum, CustomStringConvertible {
    case produce = 0
    case fetch = 1
    case listOffset = 2
    case metadata = 3
    case leaderAndIsr = 4
    case stopReplica = 5
    case updateMetadata = 6
    case controlledShutdown = 7
    case offsetCommit = 8
    case offsetFetch = 9
    case findCoordinator = 10
    case joinGroup = 11
    case heartbeat = 12
    case leaveGroup = 13
    case syncGroup = 14
    case describeGroups = 15
    case listGroups = 16
    case saslHandshake = 17
    case apiVersions = 18
    case createTopics = 19
    case deleteTopics = 20
    case deleteRecords = 21
    case initProducerId = 22
    case offsetForLeaderEpoch = 23
    case addPartitionsToTxn = 24
    case addOffsetsToTxn = 25
    case endTxn = 26
    case writeTxnMarkers = 27
    case txnOffsetCommit = 28
    case describeAcls = 29
    case createAcls = 30
    case deleteAcls = 31
    case describeConfigs = 32
    case alterConfigs = 33
    case alterReplicaLogDirs = 34
    case describeLogDirs = 35
    case saslAuthenticate = 36
    case createPartitions = 37
    case createDelegationToken = 38
    case renewDelegationToken = 39
    case expireDelegationToken = 40
    case describeDelegationToken = 41
    case deleteGroups = 42
    case electLeaders = 43
    case incrementalAlterConfigs = 44
    case alterPartitionReassignments = 45
    case listPartitionReassignments = 46
    case offsetDelete = 47
    case describeClientQuotas = 48
    case alterClientQuotas = 49

    var description: String {
        switch self {

        case .produce:
            return "Produce"
        case .fetch:
            return "Fetch"
        case .listOffset:
            return "List Offsets"
        case .metadata:
            return "Metadata"
        case .leaderAndIsr:
            return "Leader and ISR"
        case .stopReplica:
            return "Stop Replica"
        case .updateMetadata:
            return "Update Metadata"
        case .controlledShutdown:
            return "Controlled Shutdown"
        case .offsetCommit:
            return "Offset Commit"
        case .offsetFetch:
            return "Offset Fetch"
        case .findCoordinator:
            return "Find Coordinator"
        case .joinGroup:
            return "Join Group"
        case .heartbeat:
            return "Heartbeat"
        case .leaveGroup:
            return "Leave Group"
        case .syncGroup:
            return "Sync Group"
        case .describeGroups:
            return "Describe Groups"
        case .listGroups:
            return "List Groups"
        case .saslHandshake:
            return "SASL Handshake"
        case .apiVersions:
            return "API Versions"
        case .createTopics:
            return "Create Topics"
        case .deleteTopics:
            return "Delete Topics"
        case .deleteRecords:
            return "Delete Records"
        case .initProducerId:
            return "Initalize Producer ID"
        case .offsetForLeaderEpoch:
            return "Offset for Leader Epoch"
        case .addPartitionsToTxn:
            return "Add Partitions to Transaction"
        case .addOffsetsToTxn:
            return "Add Offsets to Transaction"
        case .endTxn:
            return "End Transaction"
        case .writeTxnMarkers:
            return "Write Transaction Markers"
        case .txnOffsetCommit:
            return "Transaction Offset Commit"
        case .describeAcls:
            return "Describe ACLs"
        case .createAcls:
            return "Create ACLs"
        case .deleteAcls:
            return "Delete ACLs"
        case .describeConfigs:
            return "Describe Configs"
        case .alterConfigs:
            return "Alter Configs"
        case .alterReplicaLogDirs:
            return "Alter Replica Log Dir"
        case .describeLogDirs:
            return "Describe Log Dirs"
        case .saslAuthenticate:
            return "SASL Authenticate"
        case .createPartitions:
            return "Create Partitions"
        case .createDelegationToken:
            return "Create Delegation Token"
        case .renewDelegationToken:
            return "Renew Delegation Token"
        case .expireDelegationToken:
            return "Expire Delegation Token"
        case .describeDelegationToken:
            return "Describe Delegation Token"
        case .deleteGroups:
            return "Delete Groups"
        case .electLeaders:
            return "Elect Leaders"
        case .incrementalAlterConfigs:
            return "Increment Alter Configs"
        case .alterPartitionReassignments:
            return "Alter Partition Reassignments"
        case .listPartitionReassignments:
            return "List Partition Reassignments"
        case .offsetDelete:
            return "Offset Delete"
        case .describeClientQuotas:
            return "Describe Client Quotas"
        case .alterClientQuotas:
            return "Alter Client Quotas"

        }
    }

    static func readFrom(_ byteBuffer: inout ByteBuffer) throws -> APIKey {
        guard let value = byteBuffer.readInteger(endianness: .big, as: UInt16.self) else {
            throw KafkaError.notEnoughBytes
        }
        guard let apiKey = APIKey(rawValue: value) else {
            throw KafkaError.invalidAPIKey
        }
        return apiKey
    }

    
    func messageStruct() -> (KafkaRequest.Type, KafkaResponse.Type) {
        switch (self) {
        case .metadata:
            return (MetadataRequest.self, MetadataResponse.self)
        case .apiVersions:
            return (ApiVersionsRequest.self, ApiVersionsResponse.self)
        case .findCoordinator:
            return (FindCoordinatorRequest.self, FindCoordinatorResponse.self)
        case .joinGroup:
            return (JoinGroupRequest.self, JoinGroupResponse.self)
        case .syncGroup:
            return (SyncGroupRequest.self, SyncGroupResponse.self)
        case .offsetFetch:
            return (OffsetFetchRequest.self, OffsetFetchResponse.self)
        case .fetch:
            return (FetchRequest.self, FetchResponse.self)
        case .offsetCommit:
            return (OffsetCommitRequest.self, OffsetCommitResponse.self)
        case .heartbeat:
            return (HeartbeatRequest.self, HeartbeatResponse.self)
        case .leaveGroup:
            return (LeaveGroupRequest.self, LeaveGroupResponse.self)
        case .listOffset:
            return (ListOffsetRequest.self, ListOffsetResponse.self)
        default:
            fatalError()
        }
    }

}
