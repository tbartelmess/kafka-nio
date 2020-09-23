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

extension ByteBuffer {
    mutating func read() throws -> ByteBuffer? {
        let size: Int32 = try read()
        return readSlice(length: Int(size))
    }
}
