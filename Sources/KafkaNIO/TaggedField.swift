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


struct TaggedField {
    let tag: UInt
    let value: [UInt8]
}

extension ByteBuffer {
    mutating func write(_ taggedFields: [TaggedField]) {
        write(UInt32(taggedFields.count), encoding: .varint)
    }

    mutating func read() throws -> [TaggedField] {
        let count: UInt32 = try read(encoding: .varint)
        var result = Array<TaggedField>()
        for _ in 0..<count {
            result.append(TaggedField(tag: try read(), value: try read()))
        }
        return result
    }
}
