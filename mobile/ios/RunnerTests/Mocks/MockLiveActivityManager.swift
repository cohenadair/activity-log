//
//  MockActivityManager.swift
//  Runner
//
//  Created by Cohen Adair on 2025-12-10.
//

import ActivityKit

@testable import Runner

class MockLiveActivityManager: LiveActivityManageable {
    var stubbedActivities: [LiveActivityRepresentable] = []

    var activities: [LiveActivityRepresentable] {
        stubbedActivities
    }
}
