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

/// Struct to represent a [SemVer](https://semver.org) version number
struct Version {
    let major: Int
    let minor: Int
    let patch: Int

    var string: String {
        return "\(major).\(minor).\(patch)"
    }
}

/// Version of the KafkaNIO package
let KafkaNIOVersion = Version(major: 0, minor: 0, patch: 0)
