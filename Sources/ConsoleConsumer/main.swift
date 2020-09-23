//
//  File.swift
//  
//
//  Created by Thomas Bartelmess on 2020-08-30.
//

import ArgumentParser
import KafkaNIO
import NIO

enum ConsoleConsumerError: Error, CustomStringConvertible {
    case invalidServer(server: String)

    var description: String {
        switch self {
        case .invalidServer(server: let server):
            return "Invalid Server \(server). Expected <hostname>:<port> format"
        }
    }
}

var shutdown = false
signal(SIGINT) { _ in
    print("Setting shutdown")
    shutdown = true

}

struct ConsoleConsumer: ParsableCommand {
    @Option(help: "List of boostrap servers")
    var bootstrapServer: [String]

    @Option(help: "Topic to consume on")
    var topic: String

    @Option(name: .customLong("group"), help: "Group id of the consumer.")
    var groupID: String = "swift-nio-console-consumer"

    @Option(help: "Session Timeout")
    var sessionTimeout: Int = 10000

    @Option(help: "Rebalance Timeout")
    var rebalanceTimeout: Int = 5000

    func run() throws {
        let parsedBootstrapServers = try bootstrapServer.map { name -> SocketAddress in
            let parts = name.split(separator: ":")
            guard parts.count == 2 else {
                throw ConsoleConsumerError.invalidServer(server: name)
            }
            let host = parts[0]
            guard let port = Int(parts[1]) else {
                throw ConsoleConsumerError.invalidServer(server: name)
            }
            return try SocketAddress.makeAddressResolvingHost(String(host), port: port)
        }

        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let consumer = try Consumer.connect(configuration: .init(bootstrapServers: parsedBootstrapServers,
                                                                 subscribedTopics: [topic],
                                                                 groupID: groupID,
                                                                 sessionTimeout: sessionTimeout,
                                                                 rebalanceTimeout: rebalanceTimeout),
                                            eventLoopGroup: eventLoopGroup).wait()
        try consumer.setup().wait()
        while !shutdown {
            let result = try consumer.poll().wait()
            for recordBatch in result {
                for record in recordBatch.records {
                    print("Record: \(record)")
                }
            }
        }
        try consumer.shutdown().wait()
    }
}

ConsoleConsumer.main()
