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

import NIOConcurrencyHelpers

/// Protocol for partitioners.
///
/// Partitioners are used by the `Producer` to determine the partition a message gets produced to.
protocol Partitioner {
    /// Compute the partition for the given record.
    /// - Parameters:
    ///   - topic: The topic name
    ///   - key: The serialized key to partition on (or null if no key)
    ///   - value: The serialized value to partition on or null
    ///   - partitionCount number of available partitions for the broker
    func partition(topic: Topic, key: [UInt8]?, value: [UInt8], clusterMetadata: ClusterMetadataProtocol) -> PartitionIndex

    /// Notifies the partitioner a new batch is about to be created. When using the sticky partitioner,
    /// this method can change the chosen sticky partition for the new batch.
    func newBatch(topic: Topic, clusterMetadata: ClusterMetadataProtocol, lastPartition: PartitionIndex)
}

///
/// Implementation of the default partitioner.
/// 
struct DefaultPartitioner: Partitioner {

    private let stickyPartitionerCache = StickyPartitionerCache()
    private let hashSeed: UInt32 = 0x9747b28c
    func partition(topic: Topic, key: [UInt8]?, value: [UInt8], clusterMetadata: ClusterMetadataProtocol) -> PartitionIndex {
        /// When a key is available use
        guard let key = key else {
            return 0
        }

        return 0
    }

    func newBatch(topic: Topic, clusterMetadata: ClusterMetadataProtocol, lastPartition: PartitionIndex) {
        stickyPartitionerCache
    }
}

/// Implementation of a partition cache as described in [KIP-480](https://cwiki.apache.org/confluence/display/KAFKA/KIP-480%3A+Sticky+Partitioner).
/// The cache returns the same partition for a topic until `nextPartition` is called.
/// This `class` is thread-safe and may be used from different threads
class StickyPartitionerCache {

    /// Lock to protect write access to `cache`
    private var lock = Lock()

    /// Cache of the current topic -> partition index
    var cache: [Topic: PartitionIndex] = [:]


    /// Returns the current partition for a topic
    /// - Parameters:
    ///   - topic: topic
    ///   - clusterMetadata: current cluster metadata, this is used when there is currently no partition for the `topic` in the cache.
    /// - Returns: Partition index
    func partition(for topic: Topic, clusterMetadata: ClusterMetadataProtocol) -> PartitionIndex {
        guard let partition = cache[topic] else {
            return nextPartition(for: topic, clusterMetadata: clusterMetadata, previousPartition: -1)
        }
        return partition
    }

    /// Returns the next partition to be used for a given topic
    /// - Parameters:
    ///   - topic: name of the topic
    ///   - clusterMetadata: cluster metadata to consult for available partitions
    ///   - previousPartition: partition index that was used for the last batch
    /// - Returns: next partition index for the partition, or `-1` if no partition is available
    func nextPartition(for topic: Topic,
                       clusterMetadata: ClusterMetadataProtocol,
                       previousPartition: PartitionIndex) -> PartitionIndex {
        guard var partitions = clusterMetadata.partitions(forTopic: topic)?.map({ PartitionIndex($0.partitionIndex) }) else {
            return -1
        }
        if partitions.count == 0 {
            return 0
        }
        if partitions.count == 1 || partitions.first! == previousPartition {
            return previousPartition
        }
        if partitions.count > 1 {
            partitions.removeAll { $0 == previousPartition }
        }

        guard let newPartition = partitions.randomElement() else {
            return -1
        }
        setStickyPartition(for: topic, partition: newPartition)
        return newPartition
    }

    private func setStickyPartition(for topic: Topic, partition: PartitionIndex) {
        lock.lock()
        cache[topic] = partition
        lock.unlock()
    }
}
