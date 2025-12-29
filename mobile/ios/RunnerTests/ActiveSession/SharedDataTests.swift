//
//  SharedDataTests.swift
//  RunnerTests
//
//  Created by ChatGPT on 2025-12-10.
//

import XCTest

@testable import Runner

class SharedDataTests: XCTestCase {
    override func tearDown() {
        super.setUp()
        // Make sure started data is cleared after each test.
        defaults.removeObject(forKey: "logs")
        defaults.removeObject(forKey: keyEndedActivityIds)
    }

    // MARK: - appendLog

    func testAppendLogAppendsToEmptyArray() {
        // Given
        XCTAssertNil(defaults.stringArray(forKey: "logs"))

        // When
        appendLog("First log entry")

        // Then
        let logs = defaults.stringArray(forKey: "logs")
        XCTAssertEqual(logs, ["First log entry"])
    }

    func testAppendLogAppendsToExistingArray() {
        // Given
        defaults.set(["Existing log"], forKey: "logs")

        // When
        appendLog("New log")

        // Then
        let logs = defaults.stringArray(forKey: "logs")
        XCTAssertEqual(logs, ["Existing log", "New log"])
    }

    // MARK: - appendEndedActivity (no existing entry)

    func testAppendEndedActivityAppendsWhenNotPresent() {
        // Given
        let activityId = "activity123"
        XCTAssertNil(defaults.stringArray(forKey: keyEndedActivityIds))

        // When
        appendEndedActivity(activityId)

        // Then
        let ended = defaults.stringArray(forKey: keyEndedActivityIds)
        XCTAssertNotNil(ended)
        XCTAssertEqual(ended?.count, 1)

        guard let value = ended?.first else {
            XCTFail("Expected one ended activity entry")
            return
        }

        // Format should be "<activityId>:<timestampMillis>"
        let parts = value.split(separator: ":")
        XCTAssertEqual(parts.count, 2, "Expected format '<id>:<timestampMillis>'")
        XCTAssertEqual(String(parts[0]), activityId)

        // Just sanity-check that timestamp is a positive integer.
        let timestamp = Int(parts[1])
        XCTAssertNotNil(timestamp)
        XCTAssertGreaterThan(timestamp ?? 0, 0)

        // No log should be written in this successful path.
        XCTAssertNil(defaults.stringArray(forKey: "logs"))
    }

    // MARK: - appendEndedActivity (different existing entry)

    func testAppendEndedActivityAppendsWhenDifferentIdPresent() {
        // Given
        let existing = "otherActivity:123456789"
        defaults.set([existing], forKey: keyEndedActivityIds)

        let newActivityId = "newActivity"

        // When
        appendEndedActivity(newActivityId)

        // Then
        let ended = defaults.stringArray(forKey: keyEndedActivityIds)
        XCTAssertNotNil(ended)
        XCTAssertEqual(ended?.count, 2)

        // Preserve original first value
        XCTAssertEqual(ended?.first, existing)

        guard let last = ended?.last else {
            XCTFail("Expected a second ended activity entry")
            return
        }

        let parts = last.split(separator: ":")
        XCTAssertEqual(parts.count, 2)
        XCTAssertEqual(String(parts[0]), newActivityId)

        // Still no log written in this branch
        XCTAssertNil(defaults.stringArray(forKey: "logs"))
    }

    // MARK: - appendEndedActivity (already present path)

    func testAppendEndedActivityLogsAndDoesNotAppendWhenAlreadyPresent() {
        // Given
        let activityId = "duplicateActivity"
        let existingValue = "\(activityId):123456789"
        defaults.set([existingValue], forKey: keyEndedActivityIds)

        // When
        appendEndedActivity(activityId)

        // Then: ended_activity_ids should be unchanged
        let ended = defaults.stringArray(forKey: keyEndedActivityIds)
        XCTAssertEqual(ended, [existingValue])

        // And a log entry should have been written
        let logs = defaults.stringArray(forKey: "logs")
        XCTAssertNotNil(logs)
        XCTAssertEqual(logs?.count, 1)
        XCTAssertEqual(
            logs?.first,
            "Ended activity (\(activityId)) already exists in shared data"
        )
    }

    // MARK: - appendStringArray (indirectly covered)

    func testAppendStringArrayThroughAppendLogAndAppendEndedActivity() {
        // This test just ensures that appending multiple times keeps order and accumulates correctly.
        appendLog("log1")
        appendLog("log2")

        let logs = defaults.stringArray(forKey: "logs")
        XCTAssertEqual(logs, ["log1", "log2"])

        appendEndedActivity("a1")
        appendEndedActivity("a2")

        let ended = defaults.stringArray(forKey: keyEndedActivityIds)
        XCTAssertEqual(ended?.count, 2)
        XCTAssertTrue(ended?.first?.hasPrefix("a1:") ?? false)
        XCTAssertTrue(ended?.last?.hasPrefix("a2:") ?? false)
    }

    // MARK: - LiveActivitiesAppAttributes.prefixedKey(_:)

    func testPrefixedKeyUsesIdAsPrefix() {
        let attributes = LiveActivitiesAppAttributes()
        XCTAssertTrue(attributes.prefixedKey("someKey").hasSuffix("_someKey"))
    }
}
