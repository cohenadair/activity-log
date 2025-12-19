//
//  EndSessionIntentTests.swift
//  RunnerTests
//
//  Created by ChatGPT on 2025-12-10.
//

import XCTest
import ActivityKit
import AppIntents

@testable import Runner

class EndSessionIntentTests: XCTestCase {
    private var liveActivityManager: MockLiveActivityManager!
    
    override func setUp() {
        super.setUp()
        
        liveActivityManager = MockLiveActivityManager()
        LiveActivityManager.testOnlySet(liveActivityManager)
    }
    
    override func tearDown() {
        super.tearDown()
        
        // Make sure started data is cleared after each test.
        defaults.removeObject(forKey: "logs")
        defaults.removeObject(forKey: keyEndedActivityIds)
    }

    // MARK: - Initializers & Static Properties

    func testMemberwiseInitSetsIds() {
        let intent = EndSessionIntent(
            liveActivityId: "live-id",
            appActivityId: "app-id"
        )

        XCTAssertEqual(intent.liveActivityId, "live-id")
        XCTAssertEqual(intent.appActivityId, "app-id")
    }

    func testStaticPropertiesHaveExpectedValues() {
        // Localized title
        let titleString = String(localized: EndSessionIntent.title)
        XCTAssertEqual(titleString, "End Session")

        // Discoverability
        XCTAssertFalse(EndSessionIntent.isDiscoverable)

        // openAppWhenRun extension
        XCTAssertFalse(EndSessionIntent.openAppWhenRun)

        // supportedModes (future iOS availability)
        XCTAssertEqual(EndSessionIntent.supportedModes, .background)
    }

    // MARK: - perform() – No Activities / Non-matching IDs

    func testPerformAppendsEndedActivityAndLogsActivityCountWhenNoMatchingActivity() async {
        // Setup running activities.
        let activity1 = MockLiveActivity(id: "id-0")
        let activity2 = MockLiveActivity(id: "id-1")
        liveActivityManager.stubbedActivities = [ activity1, activity2 ]
        
        let intent = EndSessionIntent(
            liveActivityId: "nonexistent-live-id",
            appActivityId: "app-id-123"
        )
        _ = await intent.perform()

        // 1) appendEndedActivity(appActivityId) should have written a single entry.
        let ended = defaults.stringArray(forKey: keyEndedActivityIds)
        XCTAssertNotNil(ended)
        XCTAssertEqual(ended?.count, 1)
        XCTAssertTrue(ended?.first?.hasPrefix("app-id-123:") ?? false)

        // 2) We should always log the number of live activities.
        let logs = defaults.stringArray(forKey: "logs") ?? []
        XCTAssertTrue(logs.contains { $0 == "Live Activities: 2" })

        // 3) Because no Activity had a matching id, we must *not* have logged
        // the 'Ending live activity...' message inside the for-loop body.
        XCTAssertFalse(logs.contains { $0.contains("Ending live activity from app intent:") })
        
        XCTAssertEqual(1, activity1.idCallCount)
        XCTAssertEqual(1, activity2.idCallCount)
    }

    // MARK: - perform() – Matching Activity Path (Template)

    func testPerformEndsMatchingLiveActivityWhenPresent() async {
        // Setup running activity.
        let activity = MockLiveActivity(id: "id-0")
        activity.stubbedEnd = {_, __ in }
        
        liveActivityManager.stubbedActivities = [activity]
        LiveActivityManager.testOnlySet(liveActivityManager)

        // Run the intent with a matching liveActivityId.
        let intent = EndSessionIntent(
            liveActivityId: activity.id,
            appActivityId: "app-id-0"
        )
        _ = await intent.perform()

        // Verify appeneded log.
        let logs = defaults.stringArray(forKey: "logs") ?? []
        XCTAssertEqual(2, logs.count)
        XCTAssertTrue(logs.last!.starts(with: "Ending live activity"))
        
        // Verify activity is ended.
        XCTAssertEqual(1, activity.endCallCount)
    }
}
