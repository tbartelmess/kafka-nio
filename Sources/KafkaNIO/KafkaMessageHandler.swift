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

class KafkaResponseHandler: ChannelInboundHandler {
    typealias InboundIn = KafkaResponse

    init(responseHandler: @escaping (KafkaResponse)->Void) {
        self.responseHandler = responseHandler
    }

    var responseHandler: (KafkaResponse)->Void
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let response = unwrapInboundIn(data)
        responseHandler(response)
    }
}
