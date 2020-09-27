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
import Logging

typealias NodeID = Int32

let logger = Logger(label: "io.bartelmess.KafkaNIO.Client")

struct Broker {
    init?(_ socketAddress: SocketAddress, rack: String? = nil) {
        guard let ip = socketAddress.ipAddress,
              let port = socketAddress.port else {
            return nil
        }
        self.host = ip
        self.port = port
        self.rack = rack
    }

    init(host: String, port: Int, rack: String? = nil) {
        self.host = host
        self.port = port
        self.rack = rack
    }
    let host: String
    let port: Int
    let rack: String?
}


enum ClientError: Error {
    case noBootstrapServer
    case serverError(ErrorCode)
}

extension Broker {

    func connect(on eventLoop: EventLoop, clientID: String, tlsConfiguration: TLSConfiguration?) -> EventLoopFuture<BrokerConnection> {
        let messageCoder = KafkaMessageCoder()
        let bootstrap = ClientBootstrap(group: eventLoop)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)

        return bootstrap.connect(host: host, port: port).flatMap { channel in

            var setupTLSFuture: EventLoopFuture<Void>

            if let tlsConfiguration = tlsConfiguration {
                do {
                    let context = try NIOSSLContext(configuration: tlsConfiguration)
                    let tlsHandler = try NIOSSLClientHandler(context: context, serverHostname: nil)
                    setupTLSFuture = channel.pipeline.addHandler(tlsHandler)
                } catch {
                    setupTLSFuture = eventLoop.makeFailedFuture(error)
                }
            } else {
                setupTLSFuture = eventLoop.makeSucceededFuture(())
            }

            return setupTLSFuture.flatMap {
                channel.pipeline.addHandlers([
                   MessageToByteHandler(messageCoder),
                   ByteToMessageHandler(messageCoder)
                ]).flatMap {
                    let connection = try! BrokerConnection(clientID: clientID, channel: channel, logger: logger)
                    return connection.setup ()
                        .map { connection }
                }
            }


        }
    }
}


protocol ClusterMetadataProtocol: CustomStringConvertible {
    var clusterID: String? {get}
    var controllerID: Int32 {get}
    var brokers: [NodeID: Broker] {get}
    var topics: [MetadataResponse.MetadataResponseTopic] {get}

    func nodeID(forTopic topic: String, partition: Int) -> NodeID?
}

extension ClusterMetadataProtocol {
    var description: String {
        return "CusterMetadata: <ClusterID:\(clusterID ?? "Unknown") ControllerID:\(controllerID)>"
    }
}

struct ClusterMetadata: ClusterMetadataProtocol, CustomStringConvertible {
    let clusterID: String?
    let controllerID: Int32
    let brokers: [NodeID: Broker]
    let topics: [MetadataResponse.MetadataResponseTopic]


    init(metadata: MetadataResponse) {
        self.clusterID = metadata.clusterID
        self.controllerID = metadata.controllerID ?? 0
        self.brokers = Dictionary(uniqueKeysWithValues: metadata.brokers.map { brokerInfo in
            (brokerInfo.nodeID,
             Broker(host: brokerInfo.host,
                    port: Int(brokerInfo.port),
                    rack: brokerInfo.rack))
        })
        self.topics = metadata.topics
    }

    func nodeID(forTopic topic: String, partition: Int) -> NodeID? {
        topics.first(where: {$0.name == topic})?.partitions.first(where: {$0.partitionIndex == partition})?.leaderID
    }
}

class Bootstrapper {
    var servers: [Broker]
    let eventLoop: EventLoop
    let tlsConfiguration: TLSConfiguration?
    let logger: Logger
    let clientID: String

    init(servers: [Broker], clientID: String, eventLoop: EventLoop, tlsConfiguration: TLSConfiguration?, logger: Logger = .init(label: "io.bartelmess.NIOKafka.Bootstrap")) {
        self.servers = servers
        self.clientID = clientID
        self.tlsConfiguration = tlsConfiguration
        self.eventLoop = eventLoop
        self.logger = logger
    }

    func nextServer() throws -> Broker {
        guard let server = servers.popLast() else {
            throw ClientError.noBootstrapServer
        }
        return server
    }

    func bootstrap() -> EventLoopFuture<BrokerConnection> {
        logger.info("Starting Bootstrap to \(servers.count) Server")
        return bootstrapRecursive()
    }

    private func bootstrapRecursive() -> EventLoopFuture<BrokerConnection> {
        let promise = eventLoop.makePromise(of: BrokerConnection.self)
        do {
            let broker = try nextServer()
            logger.info("Attempting to bootstrap with Server: \(broker.host):\(broker.port)")
            broker.connect(on: eventLoop, clientID: clientID, tlsConfiguration: tlsConfiguration)
                .flatMapError { _ in
                    return self.bootstrapRecursive()
                }
                .cascade(to: promise)
        } catch {
            promise.fail(error)
        }
        return promise.futureResult
    }
}


/// Connection pool for a cluster.
///
/// There is one `BrokerConnection` to each Node in the broker cluster.
/// Each `BrokerConnection` runs on it's own `EventLoop`
final class ClusterClient {

    let eventLoopGroup: EventLoopGroup
    let eventLoop: EventLoop
    var clusterMetadata: ClusterMetadataProtocol
    var tlsConfiguration: TLSConfiguration?
    let clientID: String
    var connectionFutures: [NodeID: EventLoopFuture<BrokerConnection>] = [:]

    static func bootstrap(servers: [Broker],
                          eventLoopGroup: EventLoopGroup,
                          clientID: String,
                          tlsConfiguration: TLSConfiguration?,
                          topics:[String] = []) -> EventLoopFuture<ClusterClient> {
        Bootstrapper(servers: servers, clientID: clientID, eventLoop: eventLoopGroup.next(), tlsConfiguration: tlsConfiguration)
            .bootstrap()
            .flatMap { (bootstrapConnection) in
                bootstrapConnection.requestFetchMetadata(topics: topics).map { ($0, bootstrapConnection) }
            }.map { (response, connection) -> (ClusterClient, BrokerConnection) in
                let initalMetadata = ClusterMetadata(metadata: response)

                return (ClusterClient(clientID: clientID, eventLoopGroup: eventLoopGroup, clusterMetadata: initalMetadata, tlsConfiguration: tlsConfiguration), connection)
            }.flatMap { clusterClient, connection in
                connection.close().map { clusterClient }
            }
    }
    private init(clientID: String, eventLoopGroup: EventLoopGroup, clusterMetadata: ClusterMetadataProtocol, tlsConfiguration: TLSConfiguration?) {
        self.clientID = clientID
        self.eventLoopGroup = eventLoopGroup
        self.clusterMetadata = clusterMetadata
        self.tlsConfiguration = tlsConfiguration
        self.eventLoop = eventLoopGroup.next()
    }

    func connectionForAnyNode() -> EventLoopFuture<BrokerConnection> {
        guard let connectionFuture = connectionFutures.randomElement() else {
            guard let nodeID = clusterMetadata.brokers.keys.randomElement() else {
                return eventLoop.makeFailedFuture(KafkaError.noKnownNode)
            }
            return connection(forNode: nodeID)
        }
        return connectionFuture.value
    }

    /// Creates a connection to a node, but doesn't store a reference to the connection for reuse.
    func createConnection(forNode nodeID: NodeID) -> EventLoopFuture<BrokerConnection> {
        eventLoop.flatSubmit {
            guard let brokerInfo = self.clusterMetadata.brokers[nodeID] else {
                return self.eventLoop.makeFailedFuture(KafkaError.unknownNodeID)
            }
            return brokerInfo.connect(on: self.eventLoopGroup.next(),
                                      clientID: self.clientID,
                                      tlsConfiguration: self.tlsConfiguration)
        }
    }
    /// Returns a `BrokerConnection` for a NodeID.
    ///
    /// The node must be part of the cluster, otherwise the future fails with `ProtocolError.unknownNodeID`
    func connection(forNode nodeID: NodeID) -> EventLoopFuture<BrokerConnection> {
        eventLoop.flatSubmit {
            guard let brokerInfo = self.clusterMetadata.brokers[nodeID] else {
                return self.eventLoop.makeFailedFuture(KafkaError.unknownNodeID)
            }
            if let connectionFuture = self.connectionFutures[nodeID] {
                return connectionFuture
            }
            let future = brokerInfo.connect(on: self.eventLoopGroup.next(), clientID: self.clientID,
                                            tlsConfiguration: self.tlsConfiguration)
            self.connectionFutures[nodeID] = future
            return future
        }
    }

    func closeConnection(forNode nodeID: NodeID) -> EventLoopFuture<Void> {
        guard let connectionFuture = connectionFutures[nodeID] else {
            return eventLoop.makeSucceededFuture(())
        }
        connectionFutures.removeValue(forKey: nodeID)
        return connectionFuture.flatMap { $0.close() }
    }

    func closeAllConnections() -> EventLoopFuture<Void> {
        let closeFutures = self.connectionFutures.keys.map { self.closeConnection(forNode: $0) }
        return EventLoopFuture.andAllComplete(closeFutures, on: self.eventLoop)
    }


    func refreshMetadata(connection: BrokerConnection, topics: [Topic]) -> EventLoopFuture<Void> {
        connection.requestFetchMetadata(topics: topics).map { response in
            self.clusterMetadata = ClusterMetadata(metadata: response)
        }
    }
}
