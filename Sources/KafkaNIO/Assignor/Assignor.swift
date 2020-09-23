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
import NIO

enum AssignmentProtocol: String, CaseIterable {
    case range = "range"

    var assignor: Assignor.Type {
        switch self {
        case .range:
            return RangeAssignor.self
        }
    }
}
struct TopicPartition: Hashable {
    init(_ topic: String, _ partition: Int) {
        self.topic = topic
        self.partition = partition
    }

    init(topic: String, partition: Int) {
        self.topic = topic
        self.partition = partition
    }

    let topic: String
    let partition: Int
}

struct MemberInfo: Hashable {
    let memberID: String
    let groupInstanceID: String?
}

struct Assignment: RawEncodable, RawDecodable, Equatable {
    internal init(partitions: [TopicPartition], userData: [UInt8]) {
        self.partitions = partitions
        self.userData = userData
    }
    
    init(from buffer: inout ByteBuffer) throws {
        if try ConsumerProtocolVersion.init(from: &buffer) != .v1 {
            throw KafkaError.unsupportedConsumerProtocolVersion
        }
        let length: Int32 = try buffer.read()
        self.partitions = try (0..<length).flatMap { _ -> [TopicPartition] in
            let topicName: String = try buffer.read()
            let partitions: [Int32] = try buffer.read()
            return partitions.map { TopicPartition(topic: topicName, partition: Int($0))}
        }
        self.userData = []
    }


    func write(into buffer: inout ByteBuffer) {
        ConsumerProtocolVersion.v1.write(into: &buffer)
        var assignments: [String: [Int32]] = [:]
        for partition in partitions {
            guard let entry = assignments[partition.topic] else {
                assignments[partition.topic] = [Int32(partition.partition)]
                continue
            }
            assignments[partition.topic] = entry + [Int32(partition.partition)]
        }
        buffer.writeInteger(Int32(assignments.count), endianness: .big, as: Int32.self)
        assignments.forEach { (topic, partitions) in
            buffer.write(topic)
            buffer.write(partitions)
        }
        buffer.writeKafkaBytes(userData)
    }

    let partitions: [TopicPartition]
    let userData: [UInt8]

    var byTopic: [Topic: [PartitionIndex]] {
        var result: [Topic: [PartitionIndex]] = [:]

        for topicPartition in self.partitions {
            var partitions = result[topicPartition.topic] ?? []
            partitions.append(topicPartition.partition)
            result[topicPartition.topic] = partitions
        }
        return result
    }
}

extension ClusterMetadata {
    var partitionsPerTopic: [Topic: Int] {
        return topics.reduce(into: Dictionary<Topic,Int>()) { (result, topic) in
            return result[topic.name] = topic.partitions.count
        }
    }
}

protocol Assignor {
    static var name: String { get }
    static func assign(clusterMetadata: ClusterMetadata,
                subscriptions: [ConsumerID: Subscription])  -> [ConsumerID: Assignment]
}


