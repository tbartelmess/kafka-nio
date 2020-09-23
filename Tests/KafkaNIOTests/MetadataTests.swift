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
@testable import KafkaNIO


class MetadataTests: XCTestCase {

    func testParsing() throws {
        var buffer = try ByteBuffer.from(fixture: "metadata-v9-response")
        let header = try KafkaResponseHeader.read(from: &buffer, correlationID: 1, version: .v1)

        let response = try MetadataResponse(from: &buffer, responseHeader: header, apiVersion: 9)
        print("Response: \(response)")
    }
}
