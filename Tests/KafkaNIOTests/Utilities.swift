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
import Foundation
import NIO


enum TestUtilitiesError: Error {
    case fixtureNotFound
}
let fixtures = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("Fixtures")
extension ByteBuffer {
    static func from(fixture: String, ofType fileExtension: String? = nil) throws -> ByteBuffer {
        var path = fixtures.appendingPathComponent(fixture)
        if let fileExtension = fileExtension {
            path.appendPathExtension(fileExtension)
        }
        if !FileManager.default.fileExists(atPath: path.path) {
            XCTFail("Fixture named: \(fixture) not found")
            throw TestUtilitiesError.fixtureNotFound
        }

        let data = try Data(contentsOf: path)
        return ByteBufferAllocator().buffer(bytes: data)
    }
}

