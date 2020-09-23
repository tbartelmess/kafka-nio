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
    func joinGroupInitial(groupCoordinator: BrokerConnection) -> EventLoopFuture<String> {
        logger.info("Joining group inital (without a member ID)")
        return groupCoordinator.requestJoinGroup(groupID: self.configuration.groupID,
                                          topics: self.configuration.subscribedTopics,
                                          sessionTimeout: Int32(self.sessionTimeout),
                                          rebalanceTimeout: Int32(self.rebalanceTimeout),
                                          memberID: "",
                                          groupInstanceID: nil)
            .flatMapResult { response -> Result<String, KafkaError> in
                if response.errorCode != .memberMemberIdRequired {
                    return .failure(KafkaError.unexpectedKafkaErrorCode(response.errorCode))
                }
                return .success(response.memberID)
            }
    }

}