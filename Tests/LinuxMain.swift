import XCTest

import KafkaNIOTests

var tests = [XCTestCaseEntry]()
tests += KafkaNIOTests.__allTests()

XCTMain(tests)
