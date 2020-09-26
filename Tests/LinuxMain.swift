import XCTest

import KafkaNIOIntegrationTests
import KafkaNIOTests

var tests = [XCTestCaseEntry]()
tests += KafkaNIOIntegrationTests.__allTests()
tests += KafkaNIOTests.__allTests()

XCTMain(tests)
