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
import Logging
import Dispatch

struct MemberMetadata {
    let memberID: String
    let groupInstanceID: String?
    let subscription: Subscription
}

enum GroupStatus {
    case unknown
    case notLeader
    case leader(memberMetadata: [MemberMetadata])
}

struct GroupInfo {
    let groupID: String
    let memberID: String
    let generationID: Int32
    let assignmentProtocol: AssignmentProtocol
    let groupStatus: GroupStatus
    let coordinator: BrokerConnectionProtocol
}

struct PartitionInfo {
    let partition: Int
    let currentLeaderEpoch: Int32
    var fetchOffset: Int64
    let logStartOffset: Int64
}

/// The consumer coordinator manages the coordination process.
/// When the consumer is the group leader it handles assignment process when a rebalance is needed,
/// and performs periodic heartbeats check if new members joined the group and a sync is needed.
///
/// It manages the offsets for `NodeConsumers` and handles the periodic committing of offsets to the Group Coordinator.
class ConsumerCoordinator {
    var offsets: [Topic: [PartitionIndex : PartitionInfo]]
    let groupInfo: GroupInfo
    let logger: Logger
    var heartbeatSchedule: RepeatedTask?
    private let queue = DispatchQueue(label: "io.bartelmess.KafkaNIO.ConsumerCoordinator")



    init(partitions: [Topic: [PartitionInfo]], groupInfo: GroupInfo, logger: Logger) {
        self.offsets = [:]
        self.groupInfo = groupInfo
        self.logger = logger
        partitions.forEach { topic, partitions in
            offsets[topic] = Dictionary(uniqueKeysWithValues: partitions.map { ($0.partition, $0) })
        }
    }


    var partitions: [PartitionInfo] {
        return []
    }

    func commitOffsets() -> EventLoopFuture<Void> {
        logger.info("Commiting offsets")
        let topics = offsets.map { topic, partitions -> OffsetCommitRequest.OffsetCommitRequestTopic in
            let topicPartitions = partitions.values.map { partitionInfo in
                OffsetCommitRequest.OffsetCommitRequestTopic.OffsetCommitRequestPartition(partitionIndex: Int32(partitionInfo.partition),
                                                                                          committedOffset: partitionInfo.fetchOffset,
                                                                                          committedLeaderEpoch: partitionInfo.currentLeaderEpoch,
                                                                                          commitTimestamp: nil,
                                                                                          committedMetadata:  nil)
            }
            return OffsetCommitRequest.OffsetCommitRequestTopic(name: topic, partitions: topicPartitions)
        }

        return groupInfo.coordinator.requestOffsetCommit(groupID: groupInfo.groupID, generationID: groupInfo.generationID, memberID: groupInfo.memberID, topics: topics).map { response in
            self.logger.info("Did commit offsets")
        }.flatMapErrorThrowing { (error) in
            self.logger.error("Failed to commit offsets: \(error)")
        }
    }



    func setOffset(_ offset: Int64, partition: PartitionIndex, topic: Topic) {
        logger.info("Setting offset \(offset) for \(topic) \(partition)")

        queue.sync {
            offsets[topic]?[partition]?.fetchOffset = offset
        }

    }

    func offset(for partitionIndex: PartitionIndex, topic: Topic) -> Int64 {
        queue.sync {
            offsets[topic]?[partitionIndex]?.fetchOffset ?? 0
        }

    }

    func partitionInfo(for partitionIndex: PartitionIndex, topic: Topic) -> PartitionInfo? {
        queue.sync {
            offsets[topic]?[partitionIndex]
        }
    }

    func leaveGroup() -> EventLoopFuture<Void> {
        groupInfo.coordinator.requestGroupLeave(groupID: self.groupInfo.groupID,
                                                memberID: self.groupInfo.memberID,
                                                groupInstanceID: nil).flatMapResult
            { response -> Result<Void, KafkaError> in
                                                    
            if response.errorCode != .noError {
                return .failure(KafkaError.unexpectedKafkaErrorCode(response.errorCode))
            }
            guard let memberResponse = response.members?.first else {
                self.logger.error("The LeaveGroup response did not contain the requested member")
                return .failure(KafkaError.invalidState)
            }
                                                    if let memberError = memberResponse.errorCode {
                                                        if memberError != .noError {
                                                            self.logger.error("Failed to leave group for member: \(memberResponse.memberID ?? "Unknown member ID"): \(memberError)")
                                                            return .failure(KafkaError.unexpectedKafkaErrorCode(memberError))
                                                    }
            }
            return .success(())
        }
    }

    func shutdown() -> EventLoopFuture<Void> {
        groupInfo.coordinator.close()
    }
}
