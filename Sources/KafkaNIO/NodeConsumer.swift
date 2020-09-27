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

class NodeConsumer {
    let BrokerConnectionProtocol: BrokerConnectionProtocol
    var partitions: [Topic : [PartitionIndex]]
    let group: String
    let eventLoop: EventLoop
    var sessionID: Int32 = 0
    var sessionEpoch: Int32 = 0
    var consumerCoordinator: ConsumerCoordinator
    var configuration: Consumer.Configuration

    private var _shutdown: Bool = false

    var currentPoll: EventLoopFuture<Void>?

    init(connection: BrokerConnectionProtocol,
         partitions: [Topic : [PartitionIndex]],
         consumerCoordinator: ConsumerCoordinator,
         configuration: Consumer.Configuration,
         group: String,
         eventLoop: EventLoop) {
        self.BrokerConnectionProtocol = connection
        self.group = group
        self.eventLoop = eventLoop
        self.partitions = partitions
        self.configuration = configuration
        self.consumerCoordinator = consumerCoordinator
    }




    func handleResponse(response: FetchResponse) -> Result<[RecordBatch], KafkaError> {
        logger.trace("Received response for FetchRequest")
        self.sessionEpoch += 1
        var batches: [RecordBatch] = []
        response.responses.forEach { topicResponse in
            topicResponse.partitionResponses.forEach { partitionResponse in
                var buffer = partitionResponse.recordSet!
                while true {
                    do {
                       let batch = try RecordBatch(from: &buffer,
                                                   topic: topicResponse.topic,
                                                   partitionIndex: PartitionIndex(partitionResponse.partition),
                                                   crcValidation: configuration.crcValidation)
                        consumerCoordinator.setOffset(batch.baseOffset+Int64(batch.lastOffsetDelta) + 1,
                                                      partition: PartitionIndex(partitionResponse.partition),
                                                      topic: topicResponse.topic)
                        batches.append(batch)
                        
                    } catch KafkaError.notEnoughBytes {
                        break
                    } catch {
                        fatalError("Unexpected Error: \(error)")
                    }
                }
            }
        }
        self.sessionID = response.sessionID ?? 0
        return .success(batches)
    }


    func poll(fetchConfiguration: Consumer.FetchConfiguration = .default) -> EventLoopFuture<[RecordBatch]> {

        // Build a Fetch Request topic from each
        let fetchTopics = partitions.map { topic, partitions -> FetchRequest.FetchTopic in
            let fetchPartitions = partitions.map { partitionIndex -> FetchRequest.FetchTopic.FetchPartition in
                guard let partitionInfo = consumerCoordinator.partitionInfo(for: partitionIndex, topic: topic) else {
                    fatalError()
                }
                return FetchRequest.FetchTopic.FetchPartition(partition: Int32(partitionInfo.partition),
                                                              currentLeaderEpoch: partitionInfo.currentLeaderEpoch,
                                                              fetchOffset: partitionInfo.fetchOffset,
                                                              logStartOffset: partitionInfo.logStartOffset,
                                                              partitionMaxBytes: 10000)
            }
            return FetchRequest.FetchTopic(topic: topic, partitions: fetchPartitions)
        }
        return BrokerConnectionProtocol.requestFetch(maxWaitTime: fetchConfiguration.maxWaitTime,
                                             minBytes: fetchConfiguration.minBytes,
                                             maxBytes: fetchConfiguration.maxBytes,
                                             sessionID: sessionID,
                                             sessionEpoch: sessionEpoch,
                                             topics: fetchTopics).flatMapResult { response in
                                                self.handleResponse(response: response)
                                             }

    }


    func shutdown() -> EventLoopFuture<Void> {
        logger.debug("Shutting down NodeConsumer")
        self._shutdown = true
        let future = self.eventLoop.makePromise(of: Void.self)
        if let current = self.currentPoll {
            current.cascade(to: future)
        } else {
            future.succeed(())
        }
        return future.futureResult
    }
}
