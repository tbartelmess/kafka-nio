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

import Foundation

extension UnsafeRawBufferPointer {
    /// Calculates the Murmur2 hash for the contents of the buffer
    func murmur2(seed: UInt32) -> UInt32 {
        let m: UInt32 = 0x5bd1e995
        let r : UInt = 24
        var result = seed ^ UInt32(count)

        for end in stride(from: startIndex, to: endIndex, by: 4) {
            let range = end..<Swift.min(end.advanced(by: 4), endIndex)
            if range.count >= 4 {
                let value = self[range].withUnsafeBytes { $0.bindMemory(to: UInt32.self).first!}
                var k = value &* m
                k ^= k >> r
                k &*= m
                result &*= m
                result ^= k
            } else {
                for index in range {
                    result ^= UInt32(self[index] << (distance(from: range.startIndex, to: range.endIndex)-1 * MemoryLayout<UInt8>.size))
                }
                result &*= m;
            }
        }
        result ^= result >> 13
        result &*= m
        result ^= result >> 15
        return result
    }
}

extension Array where Element == UInt8 {
    func murmur2(seed: UInt32) -> UInt32 {
        self.withUnsafeBytes { ptr in
            ptr.murmur2(seed: 0x5bd1e995)
        }
    }
}

extension DataProtocol {
    func murmur2(seed: UInt32) -> UInt32 {
        withUnsafeBytes(of: self) { ptr in
            ptr.murmur2(seed: 0x5bd1e995)
        }
    }
}
