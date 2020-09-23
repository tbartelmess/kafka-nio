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

extension ByteBuffer {
    static func from(fixture: String, ofType: String? = nil) throws -> ByteBuffer {
        guard let fixturePath = Bundle.module.path(forResource: fixture, ofType: ofType) else {
            XCTFail("Fixture named: \(fixture) not found")
            throw TestUtilitiesError.fixtureNotFound
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: fixturePath))
        return ByteBufferAllocator().buffer(bytes: data)
    }
}

