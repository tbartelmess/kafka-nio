#if !canImport(ObjectiveC)
import XCTest

extension APIVersions {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__APIVersions = [
        ("testGeneration", testGeneration),
        ("testParsing", testParsing),
    ]
}

extension BootstrapTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__BootstrapTests = [
        ("testBootstrap2FailureOneOk", testBootstrap2FailureOneOk),
        ("testBootstrapFailure", testBootstrapFailure),
        ("testBootstrapTLS", testBootstrapTLS),
    ]
}

extension ClusterClientOnlineTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ClusterClientOnlineTests = [
        ("testConcurrentAccess", testConcurrentAccess),
        ("testGetAll", testGetAll),
    ]
}

extension ClusterClientTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ClusterClientTests = [
        ("testConnectionForTopic", testConnectionForTopic),
        ("testEnsureHasMetadataFail", testEnsureHasMetadataFail),
        ("testEnsureHasMetadataOK", testEnsureHasMetadataOK),
        ("testEnsureHasMetadataOKFailedThenOK", testEnsureHasMetadataOKFailedThenOK),
        ("testRefreshMetadata", testRefreshMetadata),
    ]
}

extension CompactIntTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__CompactIntTests = [
        ("testUnsignedVarint", testUnsignedVarint),
    ]
}

extension ConsumerProtocolTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ConsumerProtocolTests = [
        ("testAssignmentSerialization", testAssignmentSerialization),
        ("testAssignmentSerializationOneTopicMuliplePartitions", testAssignmentSerializationOneTopicMuliplePartitions),
    ]
}

extension FetchTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__FetchTests = [
        ("testParsingAndRecordBufferDecoding", testParsingAndRecordBufferDecoding),
        ("testParsingOutOfRange", testParsingOutOfRange),
    ]
}

extension HeartbeatMessageTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__HeartbeatMessageTests = [
        ("testGeneration", testGeneration),
    ]
}

extension JoinGroupTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__JoinGroupTests = [
        ("testGeneration", testGeneration),
        ("testParsing", testParsing),
        ("testParsingInitial", testParsingInitial),
    ]
}

extension MetadataTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__MetadataTests = [
        ("testParsing", testParsing),
    ]
}

extension OffsetCommitTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__OffsetCommitTests = [
        ("testParsingVersion3", testParsingVersion3),
    ]
}

extension OffsetsTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__OffsetsTests = [
        ("testParsing", testParsing),
    ]
}

extension RangeAssignorTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__RangeAssignorTests = [
        ("testOneConsumerNonexistentTopic", testOneConsumerNonexistentTopic),
        ("testOneConsumerNoTopic", testOneConsumerNoTopic),
        ("testOneConsumerOneTopic", testOneConsumerOneTopic),
        ("testOneConsumerOneTopicMultiplePartitions", testOneConsumerOneTopicMultiplePartitions),
        ("testOnlyAssignsPartitionsFromSubscribedTopics", testOnlyAssignsPartitionsFromSubscribedTopics),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(APIVersions.__allTests__APIVersions),
        testCase(BootstrapTests.__allTests__BootstrapTests),
        testCase(ClusterClientOnlineTests.__allTests__ClusterClientOnlineTests),
        testCase(ClusterClientTests.__allTests__ClusterClientTests),
        testCase(CompactIntTests.__allTests__CompactIntTests),
        testCase(ConsumerProtocolTests.__allTests__ConsumerProtocolTests),
        testCase(FetchTests.__allTests__FetchTests),
        testCase(HeartbeatMessageTests.__allTests__HeartbeatMessageTests),
        testCase(JoinGroupTests.__allTests__JoinGroupTests),
        testCase(MetadataTests.__allTests__MetadataTests),
        testCase(OffsetCommitTests.__allTests__OffsetCommitTests),
        testCase(OffsetsTests.__allTests__OffsetsTests),
        testCase(RangeAssignorTests.__allTests__RangeAssignorTests),
    ]
}
#endif
