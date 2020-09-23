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

extension Consumer {


    func rebalance() -> EventLoopFuture<Void> {
        logger.info("Rebalancing Group: \(self.configuration.groupID)")
        guard case .consuming(groupInfo: let oldGroupInfo, consumers: let consumers, consumerCoordinator: _) = self.state else {
            return eventLoop.makeFailedFuture(KafkaError.invalidState)
        }
        let promise = eventLoop.makePromise(of: Void.self)
        self.state = .rebalancing(rebalanceFuture: promise.futureResult)

        /// Stop all nodes
        logger.debug("Stopping all consumers in group '\(configuration.groupID)'")
        let refreshFuture = self.clusterClient.refreshMetadata(connection: oldGroupInfo.coordinator, topics: self.configuration.subscribedTopics)
        let shutdownFuture = EventLoopFuture.whenAllComplete(consumers.map { $0.shutdown() }, on: self.eventLoop)
            .flatMapResult { results -> Result<Void, KafkaError> in
            let allOK = results.filter { (result) -> Bool in
                if case .failure(_) = result {
                    return true
                }
                return false
            }.isEmpty
            if allOK {
                return .success(())
            } else {
                return .failure(KafkaError.invalidState)
            }
        }
        let rebalanceFuture = EventLoopFuture.andAllSucceed([shutdownFuture, refreshFuture], on: eventLoop)

            .flatMap { result in
                self.joinKnownGroup(groupCoordinator: oldGroupInfo.coordinator, memberID: oldGroupInfo.memberID)
            }
        rebalanceFuture.cascade(to: promise)
        return promise.futureResult
    }
}
