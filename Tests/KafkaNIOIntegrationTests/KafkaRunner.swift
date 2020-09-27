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
import Stencil
import PathKit
import NIOSSL
@testable import KafkaNIO


struct ZookeeperConfig {
    let dataDir: String
    let port: Int
    let host: String
}

struct KafkaConfig {
    enum Transport: String, CustomStringConvertible {
        case plaintext = "PLAINTEXT"
        case ssl = "SSL"

        var description: String {
            rawValue
        }
    }
    struct SASLConfig {
        var string: String {
            ""
        }
    }

    struct SSLConfig {
        struct Keystore {
            let location: URL
            let keystorePassword: String
            let keyPassword: String?
        }
        let keystore: Keystore
        let truststore: Keystore
    }

    let brokerID: Int
    let transport: Transport
    let host: String
    let port: Int
    let saslConfig: SASLConfig?
    let sslConfig: SSLConfig

    let logsDir: URL
    /// Configures `num.partitions`
    let partitions: Int

    /// Configures the default replication factor for partitions `default.replication.factor`
    let replicas: Int

    let zookeepers: String
}

struct Log4JMessage {
    enum Level: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warn = "WARN"
        case error = "ERROR"
        case fatal = "FATAL"
        case trace = "TRACE"

    }
    let timestamp: Date
    let level: Level
    let message: String
}

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



enum LogError: Error {
    case failedToParseLine
    case regexFailure
    case unknownLogLevel(String)
    case timestampParseFailure(String)
}

private class Log4JParser: ChannelInboundHandler {
    typealias InboundIn = String
    typealias InboundOut = Log4JMessage

    let regex = try! NSRegularExpression(pattern: "\\[([^\\]]+)\\] (\\w+) (.*)", options: .caseInsensitive)

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss,SSS"
        return formatter
    }()

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let line = unwrapInboundIn(data)
        guard let match = regex.matches(in: line, options: [], range: NSRange(location: 0, length: line.count)).first else {
            context.fireErrorCaught(LogError.failedToParseLine)
            return
        }
        guard let dateRange = Range(match.range(at: 1), in: line),
              let levelRange = Range(match.range(at: 2), in: line),
              let messageRange = Range(match.range(at: 3), in: line) else {
            context.fireErrorCaught(LogError.regexFailure)
            return
        }
        let dateString = String(line[dateRange])
        let logLevelName = String(line[levelRange])
        guard let level =  Log4JMessage.Level(rawValue: logLevelName) else {
            context.fireErrorCaught(LogError.unknownLogLevel(logLevelName))
            return
        }
        let message = String(line[messageRange])
        guard let date = dateFormatter.date(from: dateString) else {
            context.fireErrorCaught(LogError.timestampParseFailure(dateString))
            return
        }
        let log4jMessage = Log4JMessage(timestamp: date, level: level, message: message)
        context.fireChannelRead(wrapInboundOut(log4jMessage))
    }


}

class NIOLogWatcher {
    let channel: Channel
    init<T: LogWatcher>(fileHandle: FileHandle, watcher: T, group: EventLoopGroup) throws {
        channel = try NIOPipeBootstrap.init(group: group)
            .channelOption(ChannelOptions.allowRemoteHalfClosure, value: true)
            .channelInitializer { channel in
                channel.pipeline.addHandlers(
                    [ByteToMessageHandler(NewlineFramer()),
                    Log4JParser(),
                    LogWatchHandler(watcher: watcher)]
                )
            }.withInputOutputDescriptor(dup(fileHandle.fileDescriptor))
            .wait()
    }
}


protocol LogWatcher {
    func handleMessage(_ message: Log4JMessage)
}


class LogWatchHandler<T: LogWatcher>: ChannelInboundHandler {

    var watcher: T

    init(watcher: T) {
        self.watcher = watcher
    }

    typealias InboundIn = Log4JMessage
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let message = unwrapInboundIn(data)
        watcher.handleMessage(message)
    }
}

enum ZookeeperError: Error {
    case error(Log4JMessage)
}

struct ZookeeperLogWatcher: LogWatcher {

    private let eventLoop: EventLoop
    private let startupPromise: EventLoopPromise<Void>

    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        startupPromise = eventLoop.makePromise()
    }

    enum ZookeeperStartupStatus {
        case starting
        case success
        case error(String)
    }

    var startupStatus = ZookeeperStartupStatus.success

    func handleMessage(_ message: Log4JMessage) {
        if message.message.hasPrefix("binding to port localhost/127.0.0.1:2181") {
            // Successful startup
            print("started zookeeper")
            let _ = eventLoop.submit {
                startupPromise.succeed(())
            }
        }
        if message.level == .error || message.level == .fatal {
            // Failed startup
            let _ = eventLoop.submit {
                startupPromise.fail(ZookeeperError.error(message))
            }
        }
    }

    func waitForStartup() throws {
        try startupPromise.futureResult.wait()
    }
}
enum KafkaError: Error {
    case error(Log4JMessage)
}
struct KafkaLogWatcher: LogWatcher {

    private let eventLoop: EventLoop
    private let startupPromise: EventLoopPromise<Void>

    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        startupPromise = eventLoop.makePromise()
    }

    enum KafkaStartupStatus {
        case starting
        case success
        case error(String)
    }

    var startupStatus = KafkaStartupStatus.success

    let startupRegex = try! NSRegularExpression(pattern: "\\[Kafka ?Server (id=)?[0-9]*\\],? started.*", options: [])

    func handleMessage(_ message: Log4JMessage) {
        startupRegex.matches(in: message.message, options: [], range: NSRange(location: 0, length: message.message.count))
        if !startupRegex.matches(in: message.message, options: [], range: NSRange(location: 0, length: message.message.count)).isEmpty {
            // Successful startup
            let _ = eventLoop.submit {
                startupPromise.succeed(())
            }
        }
        if message.level == .error || message.level == .fatal {
            // Failed startup
            let _ = eventLoop.submit {
                startupPromise.fail(KafkaError.error(message))
            }
        }
    }

    func waitForStartup() throws {
        try startupPromise.futureResult.wait()
    }
}



class ServerController {
    let kafkaVersion = ProcessInfo.processInfo.environment["KAFKA_VERSION"] ?? "0.9.0.1"
    let directory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
                                                   .deletingLastPathComponent()
                                                   .deletingLastPathComponent()
                                                   .appendingPathComponent("servers")

    var versionDirectory: URL {
        directory.appendingPathComponent(kafkaVersion)
    }

    var kafkaHome: URL {
        versionDirectory.appendingPathComponent("kafka-bin")
    }

    var resourcesURL: URL {
        versionDirectory.appendingPathComponent("resources")
    }


    var kafkaRunClassScript: URL {
        kafkaHome.appendingPathComponent("bin/kafka-run-class.sh")
    }

    func kafkaScript(named name: String) -> URL {
        kafkaHome.appendingPathComponent("bin").appendingPathComponent(name)
    }

    func testResource(named name: String) -> URL {
        resourcesURL.appendingPathComponent(name)
    }

    var log4jConfigFile: URL {
        testResource(named: "log4j.properties")
    }

    var logWatcher: NIOLogWatcher?
}

class ZookeeperController: ServerController {
    static let shared = ZookeeperController()

    var zookeeperConfigFile: URL {
        return zookeeperDirectory.appendingPathComponent("zookeeper.properties")
    }
    var zookeeperDataDir: URL {
        let url = zookeeperDirectory.appendingPathComponent("data")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }

    func generateZookeeperConfig() throws {
        let context = [ "zookeeperConfig": ZookeeperConfig(dataDir: zookeeperDataDir.path, port: 2181, host: "localhost") ]
        let environment = Environment(loader: FileSystemLoader(paths: [Path(resourcesURL.path)]))
        let renderedConfig = try environment.renderTemplate(name: "zookeeper.properties", context: context)
        try renderedConfig.write(to: zookeeperConfigFile, atomically: true, encoding: .utf8)
    }

    lazy var zookeeperDirectory: URL = {
        let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("kafka-nio").appendingPathComponent("zookeeper")
        try? FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true, attributes: nil)
        return temporaryDirectory
    }()

    var zookeeperProcess: Process?

    func startZookeeper() throws {
        try? FileManager.default.removeItem(atPath: zookeeperDirectory)
        let process = Process()
        try generateZookeeperConfig()
        process.executableURL = kafkaScript(named: "kafka-run-class.sh")
        process.arguments = ["org.apache.zookeeper.server.quorum.QuorumPeerMain", zookeeperConfigFile.path]
        process.environment = ["KAFKA_LOG4J_OPTS": "-Dlog4j.configuration=file:\(log4jConfigFile.path)"]

        let stdout = Pipe()
        process.standardOutput = stdout

        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let loop = group.next()
        let zookeeperStartupWatcher = ZookeeperLogWatcher(eventLoop: loop)
        logWatcher = try NIOLogWatcher(fileHandle: stdout.fileHandleForReading,
                                       watcher: zookeeperStartupWatcher,
                                       group: MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount))
        zookeeperProcess = process
        process.launch()
        try zookeeperStartupWatcher.waitForStartup()
    }

    func stopZookeeper() {
        zookeeperProcess?.interrupt()
        zookeeperProcess?.waitUntilExit()
    }
}

class KafkaController: ServerController {
    static let shared = KafkaController()

    lazy var kafkaDirectory: URL = {
        let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("kafka-nio").appendingPathComponent("kafka")
        try? FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true, attributes: nil)
        return temporaryDirectory
    }()


    var kafkaConfigFile: URL {
        return kafkaDirectory.appendingPathComponent("kafka.properties")
    }
    var kafkaDataDir: URL {
        let url = kafkaDirectory.appendingPathComponent("data")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }

    var sslDir: URL {
        let url = kafkaDirectory.appendingPathComponent("ssl")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }

    var logsDir: URL {
        let url = kafkaDirectory.appendingPathComponent("logs")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }

    var serverKeystore: URL {
        sslDir.appendingPathComponent("server.jks")
    }
    var trustKeystore: URL {
        sslDir.appendingPathComponent("trust.jks")
    }
    let keystorePassword = "kafka-test"
    func setupKeystore() throws {
        let dn = "CN=localhost, OU=testing, O=kafka-nio, L=Toronto, ST=Ontario, C=CA"
        try [trustKeystore, serverKeystore].forEach {keystore in
            if FileManager.default.fileExists(atPath: keystore.path) {
                try FileManager.default.removeItem(at: keystore)
            }
        }

        try generateKeystores(keystorePath: serverKeystore.path,
                              truststorePath: trustKeystore.path,
                             alias: "localhost",
                             validity: 1,
                             password: keystorePassword,
                         	distinguishedName: dn,
                         	dnsName: "localhost")
    }

    func setupTruststore() throws {

    }

    var sslConfig: KafkaConfig.SSLConfig {

        return .init(keystore: .init(location: serverKeystore, keystorePassword: keystorePassword, keyPassword: keystorePassword),
                     truststore: .init(location: trustKeystore, keystorePassword: keystorePassword, keyPassword: keystorePassword))
    }

    func generateKafkaConfig() throws {
        let config = KafkaConfig(brokerID: 1, transport: .plaintext, host: "localhost", port: 9092, saslConfig: nil, sslConfig: sslConfig, logsDir: logsDir, partitions: 1, replicas: 1, zookeepers: "localhost:2181/")
        let context = [ "kafkaConfig": config]
        let environment = Environment(loader: FileSystemLoader(paths: [Path(resourcesURL.path)]))
        let renderedConfig = try environment.renderTemplate(name: "kafka.properties", context: context)
        try renderedConfig.write(to: kafkaConfigFile, atomically: true, encoding: .utf8)
    }


    var kafkaProcess: Process?
    func startKafka() throws {
        try? FileManager.default.removeItem(atPath: kafkaDirectory)
        try setupKeystore()
        try generateKafkaConfig()
        let process = Process()
        process.executableURL = kafkaScript(named: "kafka-run-class.sh")
        process.arguments = ["kafka.Kafka", kafkaConfigFile.path]
        process.environment = ["KAFKA_LOG4J_OPTS": "-Dlog4j.configuration=file:\(log4jConfigFile.path)"]
        let stdout = Pipe()
        process.standardOutput = stdout

        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let loop = group.next()
        let kafkaStartupWatcher = KafkaLogWatcher(eventLoop: loop)
        logWatcher = try NIOLogWatcher(fileHandle: stdout.fileHandleForReading,
                                       watcher: kafkaStartupWatcher,
                                       group: MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount))
        kafkaProcess = process
        process.launch()
        try kafkaStartupWatcher.waitForStartup()
    }
    func stopKafka() {
        kafkaProcess?.interrupt()
        kafkaProcess?.waitUntilExit()
    }

}

