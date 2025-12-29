//
//  ActivityManager.swift
//  Runner
//
//  Created by Cohen Adair on 2025-12-10.
//

import ActivityKit

@available(iOS 17, *)
protocol LiveActivityRepresentable {
    var id: String { get }
    
    func end(
        _ content: ActivityContent<Activity<LiveActivitiesAppAttributes>.ContentState>?,
        dismissalPolicy: ActivityUIDismissalPolicy
    ) async
}

@available(iOS 17, *)
struct LiveActivity: LiveActivityRepresentable {
    var activity: Activity<LiveActivitiesAppAttributes>
    
    var id: String {
        activity.id
    }
    
    func end(_ content: ActivityContent<Activity<LiveActivitiesAppAttributes>.ContentState>?, dismissalPolicy: ActivityUIDismissalPolicy
    ) async {
        await activity.end(content, dismissalPolicy: dismissalPolicy)
    }
}

@available(iOS 17, *)
protocol LiveActivityManageable {
    var activities: [LiveActivityRepresentable] { get }
}

@available(iOS 17, *)
struct LiveActivityManager: LiveActivityManageable {
    static private var _instance: LiveActivityManageable = LiveActivityManager()
    
    static var get: LiveActivityManageable { _instance }
    
    static func testOnlySet(_ instance: LiveActivityManageable) {
        _instance = instance
    }

    var activities: [LiveActivityRepresentable] {
        Activity<LiveActivitiesAppAttributes>.activities.map {
            LiveActivity(activity: $0)
        }
    }
}
