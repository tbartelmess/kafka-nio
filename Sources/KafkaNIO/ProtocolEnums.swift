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
enum IsolationLevel: Int8, ProtocolEnum {
    case readUncommited = 0
    case readCommited = 1
}

enum CoordinatorType: Int8, ProtocolEnum {
    case group = 0
    case transaction = 1
}
