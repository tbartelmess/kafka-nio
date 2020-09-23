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
    /// Returns the length of an array.
    /// When the `.lengthEncoding` is `.varint`, the length is read according to the `COMPACT_ARRAY` specification,
    /// when it's `.bitEndian` as the `ARRAY` specification.

    /// - Returns: The number of elements in the array, or -1 when the array is null
    mutating func readArrayLength(lengthEncoding: IntegerEncoding) throws -> Int {
        switch lengthEncoding {
        case .bigEndian:
            let length: Int32 = try read(encoding: .bigEndian)
            return Int(length)
        case .varint:
            let length: UInt = try read(encoding: .varint)
            return Int(length) - 1
        }
    }

    mutating func writeArrayLength(length: Int, lengthEncoding: IntegerEncoding) {
        switch lengthEncoding {
        case .bigEndian:
            write(Int32(length), encoding: .bigEndian)
        case .varint:
            write(UInt(length+1), encoding: .varint)
        }
    }
}
