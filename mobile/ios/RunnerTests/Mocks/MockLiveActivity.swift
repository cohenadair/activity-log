//
//  MockLiveActivity.swift
//  Runner
//
//  Created by Cohen Adair on 2025-12-10.
//

import ActivityKit

@testable import Runner

class MockLiveActivity: LiveActivityRepresentable {
    var idCallCount = 0
    var endCallCount = 0
    
    var stubbedEnd: ((ActivityContent<Activity<LiveActivitiesAppAttributes>.ContentState>?, ActivityUIDismissalPolicy) -> Void)?
    
    private var _id: String
    var id: String {
        idCallCount += 1
        return _id
    }

    init(id: String) {
        _id = id
    }

    func end(
        _ content: ActivityContent<Activity<LiveActivitiesAppAttributes>.ContentState>?,
        dismissalPolicy: ActivityUIDismissalPolicy
    ) async {
        assert(stubbedEnd != nil)
        stubbedEnd!(content, dismissalPolicy)
        endCallCount += 1
    }
}
