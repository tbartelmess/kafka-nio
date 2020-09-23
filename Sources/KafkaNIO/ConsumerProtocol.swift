//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2017-2018 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import NIO

enum ConsumerProtocolVersion: Int16, RawEncodable, RawDecodable {
    func write(into buffer: inout ByteBuffer) {
        buffer.write(self.rawValue)
    }

    init(from buffer: inout ByteBuffer) throws {
        guard let version = ConsumerProtocolVersion(rawValue: try buffer.read()) else {
            throw KafkaError.invalidConsumerProtocolVersion
        }
        self = version
    }


    case v0 = 0
    case v1 = 1


}

extension FixedWidthInteger {
    func write(into buffer: inout ByteBuffer) {
        buffer.writeInteger(self,
                            endianness: .big,
                            as: Self.self)
    }
}
struct Partition: RawEncodable, RawDecodable {
    let topic: String
    let partitions: [Int32]

    func write(into buffer: inout ByteBuffer) {
        buffer.write(topic)
        buffer.write(partitions)
    }

    init(from buffer: inout ByteBuffer) throws {
        topic = try buffer.read()
        partitions = try buffer.read()
    }
}
struct Subscription: RawEncodable {
    let topics: [String]
    let userData: [UInt8]
    let ownedPartitions: [Partition]

    func write(into buffer: inout ByteBuffer) {
        buffer.writeInteger(ConsumerProtocolVersion.v1.rawValue, endianness: .big, as: Int16.self)
        buffer.writeStringArray(topics)
        buffer.writeKafkaBytes(userData)
        buffer.write(ownedPartitions)
    }

    func data() -> [UInt8] {
        var buffer = ByteBufferAllocator().buffer(capacity: 512)
        write(into: &buffer)
        return buffer.readBytes(length: buffer.readableBytes)!
    }


    internal init(topics: [String], userData: [UInt8], ownedPartitions: [Partition]) {
        self.topics = topics
        self.userData = userData
        self.ownedPartitions = ownedPartitions
    }

    init(_ buffer: inout ByteBuffer) throws {
        let _: Int16 = try buffer.read()

        // TODO: check version
        topics = try buffer.read()
        userData = try buffer.read()
        ownedPartitions = try buffer.read()
    }
}

extension JoinGroupResponse.JoinGroupResponseMember {
    func subscription() throws -> Subscription {
        var metadataBuffer = ByteBufferAllocator().buffer(capacity: metadata.count)
        metadataBuffer.writeBytes(metadata)
        return try Subscription(&metadataBuffer)
    }
}
