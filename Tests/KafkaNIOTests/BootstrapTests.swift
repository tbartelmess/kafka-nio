import XCTest
import NIO
import NIOSSL
import Logging
@testable import KafkaNIO

final class BootstrapTests: XCTestCase {
    private var group: EventLoopGroup!
    private var eventLoop: EventLoop {
        return self.group.next()
    }

    override func setUp() {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    }

    override func tearDownWithError() throws {
        try self.group.syncShutdownGracefully()
    }

    func testBootstrapFailure() throws {
        let loop = group.next()
        let bootstrapper = Bootstrapper(servers: [Broker(host: "not-available-01.bartelmess.io", port: 9092, rack: nil)], clientID: "unit-tests", eventLoop: loop, tlsConfiguration: nil)

        do {
            let _ = try bootstrapper.bootstrap().wait()
            XCTFail("This server should fail")
        } catch ClientError.noBootstrapServer {
            // All good
        } catch {
            XCTFail("Unexpected failure: \(error)")
        }
    }

    func testBootstrap2FailureOneOk() throws {
        let loop = group.next()

        let hostnames = ["not-available-01.bartelmess.io", "kafka-01.bartelmess.io", "not-available-02.bartelmess.io"]
        let servers = hostnames.map { Broker(host: $0, port: 9092, rack: nil) }

        let bootstrapper = Bootstrapper(servers: servers, clientID: "unit-tests", eventLoop: loop, tlsConfiguration: nil)
        let _ = try bootstrapper.bootstrap().wait()
    }

    func testBootstrapTLS() throws {
        var tlsConfiguration = TLSConfiguration.forClient()
        tlsConfiguration.certificateVerification = .none
        let server =  Broker(host: "kafka-01.bartelmess.io", port: 9094, rack: nil)
        let loop = group.next()
        let bootstrapper = Bootstrapper(servers: [server], clientID: "unit-tests", eventLoop: loop, tlsConfiguration: tlsConfiguration)
        let result = try bootstrapper.bootstrap().wait()
        let clusterMetadata = try result.requestFetchMetadata(topics: []).wait()
        XCTAssertEqual(clusterMetadata.brokers.count, 3)
        let broker1 = clusterMetadata.brokers[0]
        XCTAssertEqual(broker1.port, 9094)
        let broker2 = clusterMetadata.brokers[1]
        XCTAssertEqual(broker2.port, 9094)
        let broker3 = clusterMetadata.brokers[2]
        XCTAssertEqual(broker3.port, 9094)


    }
}
