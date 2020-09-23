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

import XCTest
import NIO
import Logging
@testable import KafkaNIO

class TestInboundHandler: ChannelInboundHandler {
    typealias InboundIn = Never
    typealias InboundOut = KafkaResponse

    var context: ChannelHandlerContext?

    func handlerAdded(context: ChannelHandlerContext) {
        self.context = context
    }

    func send(message: KafkaResponse) {
        let data = wrapInboundOut(message)
        self.channelRead(context: context!, data: data)

    }
}

class TestOutboundHandler: ChannelOutboundHandler {
    typealias OutboundIn = KafkaRequest


    var messageHandler: ((KafkaRequest)->Void)?

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let message = unwrapOutboundIn(data)
        messageHandler?(message)
    }
}
