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
    func syncGroup(groupInfo: GroupInfo) -> EventLoopFuture<Assignment> {
        let assignments: [ConsumerID : Assignment]
        switch groupInfo.groupStatus {
        case .leader(memberMetadata: let memberMetadata):
            let assignor = groupInfo.assignmentProtocol.assignor
            let subscriptions = memberMetadata.reduce(into: Dictionary<ConsumerID, Subscription>()) { (result, memberMetadata) in
                return result[memberMetadata.memberID] = memberMetadata.subscription
            }
            assignments = assignor.assign(clusterMetadata: self.clusterClient.clusterMetadata,
                                              subscriptions: subscriptions)
        default:
            assignments = [:]
        }

        return groupInfo.coordinator.requestSyncGroup(groupID: self.configuration.groupID,
                                                      generationID: groupInfo.generationID,
                                                      memberID: groupInfo.memberID,
                                                      groupInstanceID: nil,
                                                      protocolName: groupInfo.assignmentProtocol.rawValue,
                                                      assignments: assignments)
            .flatMapResult { response -> Result<Assignment, KafkaError> in
                guard response.errorCode == .noError else {
                    return .failure(.unexpectedKafkaErrorCode(response.errorCode))
                }
                do {
                    return .success(try Assignment(from: response.assignment))
                } catch let error as KafkaError {
                    return .failure(error)
                } catch {
                    fatalError("Unexpected error: \(error)")
                }

            }
    }
}
