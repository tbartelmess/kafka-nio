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
    func joinGroup(groupCoordinator: BrokerConnection, memberID: String) -> EventLoopFuture<GroupInfo> {
        logger.info("Joining group as with memberID: \(memberID)")
        return groupCoordinator.requestJoinGroup(groupID: self.configuration.groupID,
                                          topics: configuration.subscribedTopics,
                                          sessionTimeout: Int32(configuration.sessionTimeout),
                                          rebalanceTimeout: Int32(configuration.rebalanceTimeout),
                                          memberID: memberID,
                                          groupInstanceID: nil)
            .flatMapResult { response -> Result<GroupInfo, KafkaError> in
                guard response.errorCode == .noError else {
                    logger.error("Failed to join group: \(response.errorCode)")
                    return .failure(.unexpectedKafkaErrorCode(response.errorCode))
                }

                guard let protocolName = response.protocolName,
                      let assignmentProtocol = AssignmentProtocol(rawValue: protocolName) else {
                    return .failure(.unsupportedAssignmentProtocol)
                }

                let groupStatus: GroupStatus
                if response.leader == memberID {
                    do {
                        let memberMetadata = try response.members.map { responseMember -> MemberMetadata in
                            let subscription = try responseMember.subscription()
                            return MemberMetadata(memberID: responseMember.memberID,
                                                  groupInstanceID: responseMember.groupInstanceID,
                                                  subscription: subscription)
                        }
                        groupStatus = .leader(memberMetadata: memberMetadata)
                    } catch let error as KafkaError {
                        return .failure(error)
                    } catch {
                        fatalError("Unexpected error: \(error)")
                    }
                } else {
                    groupStatus = .notLeader
                }

                let groupInfo = GroupInfo(groupID: self.configuration.groupID,
                                          memberID: memberID,
                                          generationID: response.generationID,
                                          assignmentProtocol: assignmentProtocol,
                                          groupStatus: groupStatus,
                                          coordinator: groupCoordinator)

                return .success(groupInfo)
            }
    }
}
