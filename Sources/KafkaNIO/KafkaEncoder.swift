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

protocol KafkaRequest {
    var apiKey: APIKey { get }
    var apiVersion: APIVersion { get }
    var correlationID: Int32 { get }
    var clientID: String? { get }
    func write(into buffer: inout ByteBuffer) throws
}

struct KafkaResponseHeader {
    let correlationID: Int32
    let version: APIResponseHeaderVersion
    static func read(from buffer: inout ByteBuffer, correlationID: Int32, version: APIResponseHeaderVersion) throws -> KafkaResponseHeader {

        if version >= .v1 {
           let _ : [TaggedField] = try buffer.read()
        }
        let header = KafkaResponseHeader(correlationID: correlationID, version: version)
        return header
    }
}

protocol KafkaResponse {
    init(from buffer: inout ByteBuffer, responseHeader: KafkaResponseHeader, apiVersion: APIVersion) throws
    var responseHeader: KafkaResponseHeader { get }
}

enum APIRequestHeaderVersion: Int, Comparable {
    static func < (lhs: APIRequestHeaderVersion, rhs: APIRequestHeaderVersion) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    case v0 = 0
    case v1 = 1
    case v2 = 2
}

enum APIResponseHeaderVersion: Int, Comparable {
    static func < (lhs: APIResponseHeaderVersion, rhs: APIResponseHeaderVersion) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    case v0 = 0
    case v1 = 1
}
extension KafkaRequest {
    func writeHeader(into buffer: inout ByteBuffer, version: APIRequestHeaderVersion = .v1) {
        buffer.writeInteger(apiKey.rawValue)
        buffer.writeInteger(apiVersion)
        buffer.writeInteger(correlationID)
        if version >= .v1 {
            buffer.writeNullableString(clientID)
        }
        if version >= .v2 {
            buffer.write([] as [TaggedField])
        }
    }
}


final class KafkaMessageCoder : ByteToMessageDecoder, MessageToByteEncoder {
    var correlations: [Int32: (APIKey, APIVersion)] = [:]

    typealias OutboundIn = KafkaRequest

    func encode(data: KafkaRequest, out: inout ByteBuffer) throws {
        correlations[data.correlationID] = (data.apiKey, data.apiVersion)
        var byteBuffer = ByteBufferAllocator().buffer(capacity: 512)
        try data.write(into: &byteBuffer)
        out.writeInteger(Int32(byteBuffer.readableBytes))
        out.writeBuffer(&byteBuffer)
    }

    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        guard let size = buffer.getInteger(at: 0, endianness: .big, as: Int32.self),
              buffer.readableBytes >= Int(size) + MemoryLayout<Int32>.size else {
            return .needMoreData
        }

        buffer.moveReaderIndex(forwardBy: MemoryLayout<Int32>.size)
        guard var messageBuffer = buffer.readSlice(length: Int(size)) else {
            fatalError()
        }

        let correlationID: Int32 = try messageBuffer.read()

        guard let (apiKey, apiVersion) = correlations[correlationID] else {
            throw KafkaError.responseBeforeRequest
        }
        let headerVersion = apiKey.responseHeaderVersion(for: apiVersion)

        let (_, responseType) = apiKey.messageStruct()
            let responseHeader = try KafkaResponseHeader.read(from: &messageBuffer, correlationID: correlationID, version: headerVersion)
            let response = try responseType.init(from: &messageBuffer, responseHeader: responseHeader, apiVersion: apiVersion)
            logger.trace("Response: \(response)")
            context.fireChannelRead(wrapInboundOut(response))

        return .continue
    }

    func decodeLast(context: ChannelHandlerContext, buffer: inout ByteBuffer, seenEOF: Bool) throws -> DecodingState {
        return .continue
    }

    typealias InboundOut = KafkaResponse


}
