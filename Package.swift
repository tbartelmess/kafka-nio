// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KafkaNIO",
    products: [
        .library(
            name: "KafkaNIO",
            targets: ["KafkaNIO"]),
        .executable(name: "ConsoleConsumer", targets: ["ConsoleConsumer"])
    ],
    
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
        
    ],
    targets: [
        .target(
            name: "KafkaNIO",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "Logging", package: "swift-log")]),
        .testTarget(
            name: "KafkaNIOTests",
            dependencies: ["KafkaNIO"],
            resources: [.process("Fixtures")]),
        .target(name: "ConsoleConsumer",
                dependencies: [.byName(name: "KafkaNIO"),
                               .product(name: "ArgumentParser", package: "swift-argument-parser")])
    ]
)