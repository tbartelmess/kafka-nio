# KafkaNIO
[![License](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![Swift](https://img.shields.io/badge/Swift-5.3-brightgreen.svg?colorA=orange&colorB=4E4E4E)](https://swift.org)
[![Build Status](https://img.shields.io/github/workflow/status/tbartelmess/kafka-nio/test-on-linux)](https://github.com/tbartelmess/kafka-nio/actions?query=workflow%3Atest-on-linux)


KafkaNIO is a library to interact with [Apache Kafka](https://kafka.apache.org) from the Swift Server ecosystem.

It's built on top of Swift-NIO and implements the Kafka binary protocol.


## Project state
This project is still in a very early state and not ready for production use, or even to interact with production clusters.

## Installation
To install KafkaNIO, add the package as a dependency in your [Package.swift](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md#dependencies).

```swift
dependencies: [
    .package(url: "https://github.com/tbartelmess/kafka-nio.git", .upToNextMinor(from: "0.0.1"))
]
```
## Consumer API

The Consumer API allows fetching records from a Kafka broker. The main consumer API is `poll()`, which returns an `EventLoopFuture` that gets fulfilled when all brokers that hold partitions for the subscribed topics return.

### Connecting to Kafka

To connect to a Kafka Cluster, at least one address for a broker is required, from this broker the rest of the cluster state will be discovered.
It is possible to provide a list of "bootstrap servers", when a broker is not available the client will attempt to bootstrap using the next cluster in the list.


```swift
import NIO
import KafkaNIO

// Create a socket address of a Kafka Server
let bootstrapServer = try SocketAddress.makeAddressResolvingHost(String("my-kafka-host"), port: 9092)

// Create an EventLoopGroup for the consumer
let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

let consumer = try Consumer.connect(configuration: .init(bootstrapServers: [bootstrapServer],
                                                         subscribedTopics: ["my-topic"],
                                                         groupID: "my-group-id",
                                                         sessionTimeout: 10000,
                                                         rebalanceTimeout: 5000),
                                                         eventLoopGroup: eventLoopGroup).wait()
// Call setup, this will bootstrap the cluster and set up the subscription
try consumer.setup().wait()

// Poll for records
try consumer.poll().wait()
```


## Supported Features

| KIP | Status |
|:--|:--|
| [KIP-394: Require member.id for initial join group request](https://cwiki.apache.org/confluence/display/KAFKA/KIP-394%3A+Require+member.id+for+initial+join+group+request) |   Supported. |

## Supported Kafka Versions

All Kafka versions starting at 0.8 are supported. Some features are not available on some version of Kafka.

The integration test suite runs tests on the following versions:

- 0.10.2.2
- 0.11.0.3
- 1.1.1
- 2.4.0
- 2.5.0
