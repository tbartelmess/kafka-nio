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
extension OffsetFetchResponse {
    /// Returns all
    fileprivate func missingOffsets() -> [(String, [OffsetFetchResponse.OffsetFetchResponseTopic.OffsetFetchResponsePartition])] {
        topics.map { topic in
            let filteredPartitions = topic.partitions.filter { $0.committedOffset == -1 }
            return (topic.name, filteredPartitions)
        }.filter { (name, partitions) in
            !partitions.isEmpty
        }

    }
}
extension Consumer {
    /// Fetch the offsets for the consumer group using the `offsetFetch` request.
    /// When there is no known offset for the consumer group, the earliest available offset will for the topic partition will be fetched using the `offsets`
    /// command.
    func fetchOffsets(groupInfo: GroupInfo, assignment: Assignment) -> EventLoopFuture<[Topic: [PartitionInfo]]> {
        let topics = assignment.byTopic.map { key, value in
            OffsetFetchRequest.OffsetFetchRequestTopic(name: key, partitionIndexes: value.map { Int32($0) } )
        }

        return groupInfo.coordinator.requestOffsetFetch(topics: topics, groupID: configuration.groupID)
            .flatMapResult { response -> Result<[Topic: [PartitionInfo]], KafkaError> in
                guard response.errorCode == .noError else {
                    return .failure(.unexpectedKafkaErrorCode(response.errorCode!))
                }
                var result: [Topic: [PartitionInfo]] = [:]
                response.topics.forEach { topic in
                    result[topic.name] = topic.partitions.map { $0.partitionInfo }
                }
                return .success(result)
            }.flatMap { successful in
                self.fetchMissingOffsets(groupInfo: groupInfo, topics: successful)
            }
    }

    private func fetchMissingOffsets(groupInfo: GroupInfo, topics: [Topic: [PartitionInfo]]) -> EventLoopFuture<[Topic: [PartitionInfo]]> {
        let missing = topics.map { (topic, partitions) -> (Topic, [PartitionInfo]) in
            let partitionsWithMissingOffsets = partitions.filter { $0.logStartOffset == -1 }
            return (topic, partitionsWithMissingOffsets)
        }.filter { !$0.1.isEmpty }
        if missing.isEmpty {
            return eventLoop.makeSucceededFuture(topics)
        }


        // Missing offsets

        // The missing offsets need to be fetched from the leader for each partition

        let byNode: [NodeID: [Topic:[PartitionInfo]]] = missing.reduce(into: [:]) { (result, topicPartitions) in
            topicPartitions.1.forEach { partitionInfo in
                let leaderNode = clusterClient.clusterMetadata.nodeID(forTopic: topicPartitions.0, partition: partitionInfo.partition)!
                var perNode = result[leaderNode] ?? [:]
                var nodeTopics = perNode[topicPartitions.0] ?? []
                nodeTopics.append(partitionInfo)
                perNode[topicPartitions.0] = nodeTopics
                result[leaderNode] = perNode
            }
        }

        let listOffsetsFutures = byNode.map { nodeID, topicPartitions in
            clusterClient.connection(forNode: nodeID).flatMap { connection -> EventLoopFuture<ListOffsetResponse> in
                connection.requestOffsets(isolationLevel: .readCommited, topics: topicPartitions.map { topic, partitions in
                    ListOffsetRequest.ListOffsetTopic(name: topic, partitions: partitions.map({ partitionInfo in
                        ListOffsetRequest.ListOffsetTopic.ListOffsetPartition.init(partitionIndex: Int32(partitionInfo.partition), currentLeaderEpoch: partitionInfo.currentLeaderEpoch, timestamp: -1, maxNumOffsets: 1)
                    }))
                })
            }
        }


        // Start of with a list of offsets that are known
        var result: [Topic: [PartitionInfo]] = topics.reduce(into: [:]) { (result, topicPartition) in
            let partitionsWithOffsets = topicPartition.value.filter { $0.logStartOffset != -1 }
            if !partitionsWithOffsets.isEmpty {
                var partitions = result[topicPartition.key] ?? []
                partitions.append(contentsOf: partitionsWithOffsets)
                result[topicPartition.key] = partitions
            }
           }


        return EventLoopFuture.whenAllSucceed(listOffsetsFutures, on: eventLoop).map { responses in
            responses.forEach { response in
                response.topics.forEach { topic in
                    var topics = result[topic.name] ?? []
                    topics.append(contentsOf: topic.partitions.map { $0.partitionInfo })
                    result[topic.name] = topics
                }

            }
            return result
        }



    }
}
extension ListOffsetResponse.ListOffsetTopicResponse.ListOffsetPartitionResponse {
    var partitionInfo: PartitionInfo {
        PartitionInfo(partition: Int(partitionIndex),
                      currentLeaderEpoch: self.leaderEpoch ?? 0,
                      fetchOffset: self.offset ?? 0,
                      logStartOffset: self.offset ?? 0 )
    }
}
