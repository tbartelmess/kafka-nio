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

extension Consumer {
    public struct FetchConfiguration {
        public init(maxWaitTime: Int, minBytes: Int, maxBytes: Int) {
            self.maxWaitTime = maxWaitTime
            self.minBytes = minBytes
            self.maxBytes = maxBytes
        }
        public let maxWaitTime: Int
        public let minBytes: Int
        public let maxBytes: Int

        public static let `default` = FetchConfiguration(maxWaitTime: 500, minBytes: 1, maxBytes: 52428800)
    }
}
