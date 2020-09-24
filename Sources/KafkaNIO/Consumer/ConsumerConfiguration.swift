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
import NIOSSL
extension Consumer {

    /// `Consumer` configuration.
    public struct Configuration {
        public enum AutoCommit {
            case off
            case interval(amount: TimeAmount)
        }

        /// List of bootstrap servers. The bootstrap server is used to fetch the initial cluster state.
        /// Bootstrap servers are contacted sequentially, if first server that is reachable will be used
        /// to discover all relevant nodes in the cluster.
        public let bootstrapServers: [SocketAddress]

        /// List of topics the consumer is subscribed to
        public let subscribedTopics: [Topic]

        /// A name for this client. This string is passed in each request to servers and can be used to identify specific
        /// server-side log entries that correspond to this client.
        /// Also submitted to GroupCoordinator for logging with respect to consumer group administration.
        public let clientID: String

        /// The name of the consumer group to join for dynamic partition assignment
        /// and to use for fetching and committing offsets.
        public let groupID: String

        /// Group Instance ID of the group
        public let groupInstanceID: String?

        /// Session timeout for the consumer. When the broker doesn't receive a heartbeat from the consumer
        /// within this interval, the coordinator will declare the node as dead.
        public let sessionTimeout: Int

        /// Timeout for rebalance operations
        public let rebalanceTimeout: Int

        /// Auto commit settings.
        public let autoCommit: AutoCommit

        /// TLS Configuration to connect to the Kafka broker.
        /// See the [swift-nio-ssl configuration](https://apple.github.io/swift-nio-ssl/docs/current/NIOSSL/Structs/TLSConfiguration.html) for details
        public let tlsConfiguration: TLSConfiguration?

        /// Control if the CRC checksum on record batches recieved from the servers should
        /// be validated to detect corruption. Unless you have very high throughput requirements
        /// and can handle invalid data, it's recommended enable CRC validation.
        public let crcValidation: Bool

        public init(bootstrapServers: [SocketAddress],
                    subscribedTopics: [Topic],
                    clientID: String = "kafka-nio",
                    groupID: String,
                    groupInstanceID: String? = nil,
                    sessionTimeout: Int,
                    rebalanceTimeout: Int,
                    autoCommit: Configuration.AutoCommit = .interval(amount: .seconds(5)),
                    crcValidation: Bool = true,
                    tlsConfiguration: TLSConfiguration? = nil) {

            self.bootstrapServers = bootstrapServers
            self.subscribedTopics = subscribedTopics
            self.clientID = clientID
            self.groupID = groupID
            self.groupInstanceID = groupInstanceID
            self.sessionTimeout = sessionTimeout
            self.rebalanceTimeout = rebalanceTimeout
            self.autoCommit = autoCommit
            self.crcValidation = crcValidation
            self.tlsConfiguration = tlsConfiguration
        }


    }
}
