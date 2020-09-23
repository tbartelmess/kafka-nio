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


/// The range assingor works on per-topic basis. For each topic we lay out the available partitions in a numberic order and the consumers in lexicographic order.
/// When we divide the number of partitions by the total number of consumers to determine the number of partitions to assign to each consumer. If it doesn't divide evently, then the first few consumers will have one extra partition.
///
/// # Example:
/// Assume there are two consumers `C0` and `C1`, to topics `t0` and `t1`, and each topic has 3 partitions, resulting in the partitions `t0p0`,
/// `t0p1`, `t0p2`, `t1p0`, `t1p1`, and `t1p2`.
///
/// The assignment will be:
///
/// - **C0:** `[t0p0, t0p1, t1p0, t1p1]`
/// - **C1:** `[t0p2, t1p2]`
class RangeAssignor: Assignor {


    static let name = "range"

    static func assign(clusterMetadata: ClusterMetadata, subscriptions: [ConsumerID : Subscription]) -> [ConsumerID : Assignment] {
        assign(partitionsPerTopic: clusterMetadata.partitionsPerTopic,
               subscriptions: subscriptions)
        .mapValues {
            Assignment(partitions: $0, userData: [])
        }
    }

    /// Performs the assignment.
    ///
    /// - Parameters:
    ///   - partitionsPerTopic: Dictionary with all known topics and the number of partitions.
    ///   - subscriptions: Dictionary of all consumers in the group and their subscriptions
    /// - Returns: Dictionary with all assignments for all member in the group.
    static func assign(partitionsPerTopic: [Topic: Int],
                subscriptions: [ConsumerID: Subscription]) -> [ConsumerID: [TopicPartition]] {

        logger.info("Running assignment for \(subscriptions)")
        var result = subscriptions.reduce(into: [ConsumerID: [TopicPartition]]()) { (result, item) in
            result[item.key] =  [TopicPartition]()
        }
        for (topic, partitions) in partitionsPerTopic {
            let subscribedConsumers = subscriptions
                .filter { $1.topics.contains(topic) }
                .map { $0.key }
                .sorted()

            let topicPartitions = (0..<partitions).map { TopicPartition(topic: topic, partition: $0) }
                .sorted(by: { $0.partition < $1.partition } )

            let partitionsPerConsumer = topicPartitions.count / subscribedConsumers.count
            let consumersWithExtraPartition = topicPartitions.count % subscribedConsumers.count
            for (index, consumer) in subscribedConsumers.enumerated() {
                let start = partitionsPerConsumer * index + min(index, consumersWithExtraPartition)
                let count = partitionsPerConsumer + (index + 1 > consumersWithExtraPartition ? 0 : 1)
                result[consumer]?.append(contentsOf: topicPartitions[start..<start+count])
            }
        }
        return result

    }
}
