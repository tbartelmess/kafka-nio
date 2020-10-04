

import ArgumentParser
import NIO
import Dispatch
import Logging
import KafkaNIO



private struct NewlineFramer: ByteToMessageDecoder {
    typealias InboundOut = String

    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        if let firstNewline = buffer.readableBytesView.firstIndex(of: UInt8(ascii: "\n")) {
            let length = firstNewline - buffer.readerIndex + 1
            let line = String(buffer.readString(length: length)!.dropLast())
            print("Line: \(line)")
            context.fireChannelRead(self.wrapInboundOut(line))
            return .continue
        } else {
            return .needMoreData
        }
    }
}

private class KafkaProducerSender: ChannelInboundHandler {
    typealias InboundIn = String

    let producer: Producer<UTF8StringSerializer>

    init(producer: Producer<UTF8StringSerializer>) {
        self.producer = producer
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let line = unwrapInboundIn(data)
        producer.produce(topic: "foo", value: line)
    }
}

enum ConsoleProducerError: Error, CustomStringConvertible {
    case invalidServer(server: String)

    var description: String {
        switch self {
        case .invalidServer(server: let server):
            return "Invalid Server \(server). Expected <hostname>:<port> format"
        }
    }
}

var shutdownSemaphore = DispatchSemaphore(value: 0)
struct ConsoleProducer: ParsableCommand {


    @Option(help: "List of boostrap servers")
    var bootstrapServer: [String]

    @Option(help: "Topic to consume on")
    var topic: String



    func run() throws {

        var logger = Logger(label: "KafkaLogger")
        logger.logLevel = .trace
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        let parsedBootstrapServers = try bootstrapServer.map { name -> SocketAddress in
            let parts = name.split(separator: ":")
            guard parts.count == 2 else {
                throw ConsoleProducerError.invalidServer(server: name)
            }
            let host = parts[0]
            guard let port = Int(parts[1]) else {
                throw ConsoleProducerError.invalidServer(server: name)
            }
            return try SocketAddress.makeAddressResolvingHost(String(host), port: port)
        }

        let producer = try Producer<UTF8StringSerializer>.connection(configuration: .init(batchSize: 1, linger: nil, memory: 65565, bootstrapServers: parsedBootstrapServers, tlsConfiguration: nil, clientID: "swift-nio-console-producer"), eventLoopGroup: group, logger: logger).wait()
        let bootstrap = NIOPipeBootstrap.init(group: group)
            .channelInitializer { (channel) -> EventLoopFuture<Void> in
                channel.pipeline.addHandlers(
                    [
                        ByteToMessageHandler(NewlineFramer()),
                        KafkaProducerSender(producer: producer)
                    ]
                )

            }.withInputOutputDescriptor(dup(STDIN_FILENO))
        let connection = try! bootstrap.wait()


        shutdownSemaphore.wait()
        try connection.close().wait()
        print("Shutdown")

    }


}

ConsoleProducer.main()
