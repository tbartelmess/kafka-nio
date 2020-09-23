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

extension APIKey {
    func requestHeaderVersion(for version: APIVersion) -> APIRequestHeaderVersion {
        switch self {
        case .produce:
            return .v1
        case .fetch:
            return .v1
        case .listOffset:
            return .v1
        case .metadata:
            if version >= 9 {
                return .v2
            }
            return .v1
        case .leaderAndIsr:
            if version >= 4 {
                return .v2
            }
            return .v1
        case .stopReplica:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .updateMetadata:
            if version >= 6 {
                return .v2
            }
            return .v1
        case .controlledShutdown:
            if version == 0 {
                return .v0
            }
            if version >= 3 {
                return .v2
            }
            return .v1
        case .offsetCommit:
            if version >= 8 {
                return .v2
            }
            return .v1
        case .offsetFetch:
            if version >= 6 {
                return .v2
            }
            return .v1
        case .findCoordinator:
            if version >= 3 {
                return .v2
            }
            return .v1
        case .joinGroup:
            if version >= 6 {
                return .v2
            }
            return .v1
        case .heartbeat:
            if version >= 4 {
                return .v2
            }
            return .v1
        case .leaveGroup:
            if version >= 4 {
                return .v2
            }
            return .v1
        case .syncGroup:
            if version >= 4 {
                return .v2
            }
            return .v1
        case .describeGroups:
            if version >= 5 {
                return .v2
            }
            return .v1
        case .listGroups:
            if version >= 3 {
                return .v2
            }
            return .v1
        case .saslHandshake:
            return .v1
        case .apiVersions:
            if version >= 3 {
                return .v2
            }
            return .v1
        case .createTopics:
            if version >= 5 {
                return .v2
            }
            return .v1
        case .deleteTopics:
            if version >= 4 {
                return .v2
            }
            return .v1
        case .deleteRecords:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .initProducerId:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .offsetForLeaderEpoch:
            return .v1
        case .addPartitionsToTxn:
            return .v1
        case .addOffsetsToTxn:
            return .v1
        case .endTxn:
            return .v1
        case .writeTxnMarkers:
            return .v1
        case .txnOffsetCommit:
            if version >= 3 {
                return .v2
            }
            return .v1
        case .describeAcls:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .createAcls:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .deleteAcls:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .describeConfigs:
            return .v1
        case .alterConfigs:
            return .v1
        case .alterReplicaLogDirs:
            return .v1
        case .describeLogDirs:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .saslAuthenticate:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .createPartitions:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .createDelegationToken:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .renewDelegationToken:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .expireDelegationToken:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .describeDelegationToken:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .deleteGroups:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .electLeaders:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .incrementalAlterConfigs:
            if version >= 2 {
                return .v2
            }
            return .v1
        case .alterPartitionReassignments:
            return .v2
        case .listPartitionReassignments:
            return .v2
        case .offsetDelete:
            return .v1
        case .describeClientQuotas:
            return .v1
        case .alterClientQuotas:
            return .v1
        }
    }

    func responseHeaderVersion(for version: APIVersion) -> APIResponseHeaderVersion {
        switch self {
        case .produce:
            return .v0
        case .fetch:
            return .v0
        case .listOffset:
            return .v0
        case .metadata:
            if version >= 9 {
                return .v1
            }
            return .v0
        case .leaderAndIsr:
            if version >= 4 {
                return .v1
            }
            return .v0
        case .stopReplica:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .updateMetadata:
            if version >= 6 {
                return .v1
            }
            return .v0
        case .controlledShutdown:
            if version == 0 {
                return .v0
            }
            if version >= 3 {
                return .v1
            }
            return .v1
        case .offsetCommit:
            if version >= 8 {
                return .v1
            }
            return .v0
        case .offsetFetch:
            if version >= 6 {
                return .v1
            }
            return .v0
        case .findCoordinator:
            if version >= 3 {
                return .v1
            }
            return .v0
        case .joinGroup:
            if version >= 6 {
                return .v1
            }
            return .v0
        case .heartbeat:
            if version >= 4 {
                return .v1
            }
            return .v0
        case .leaveGroup:
            if version >= 4 {
                return .v1
            }
            return .v0
        case .syncGroup:
            if version >= 4 {
                return .v1
            }
            return .v0
        case .describeGroups:
            if version >= 5 {
                return .v1
            }
            return .v0
        case .listGroups:
            if version >= 3 {
                return .v1
            }
            return .v0
        case .saslHandshake:
            return .v0
        case .apiVersions:
            // ApiVersionsResponse always includes a v0 header.
            // See KIP-511 for details.
            return .v0
        case .createTopics:
            if version >= 5 {
                return .v1
            }
            return .v0
        case .deleteTopics:
            if version >= 4 {
                return .v1
            }
            return .v1
        case .deleteRecords:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .initProducerId:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .offsetForLeaderEpoch:
            return .v0
        case .addPartitionsToTxn:
            return .v0
        case .addOffsetsToTxn:
            return .v0
        case .endTxn:
            return .v0
        case .writeTxnMarkers:
            return .v0
        case .txnOffsetCommit:
            if version >= 3 {
                return .v1
            }
            return .v0
        case .describeAcls:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .createAcls:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .deleteAcls:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .describeConfigs:
            return .v0
        case .alterConfigs:
            return .v0
        case .alterReplicaLogDirs:
            return .v0
        case .describeLogDirs:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .saslAuthenticate:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .createPartitions:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .createDelegationToken:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .renewDelegationToken:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .expireDelegationToken:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .describeDelegationToken:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .deleteGroups:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .electLeaders:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .incrementalAlterConfigs:
            if version >= 2 {
                return .v1
            }
            return .v0
        case .alterPartitionReassignments:
            return .v1
        case .listPartitionReassignments:
            return .v1
        case .offsetDelete:
            return .v0
        case .describeClientQuotas:
            return .v0
        case .alterClientQuotas:
            return .v0
        }
    }
}
