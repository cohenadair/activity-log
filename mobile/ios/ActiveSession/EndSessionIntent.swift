//
//    EndSessionIntent.swift
//    Runner
//
//    Created by Cohen Adair on 2025-10-09.
//

import AppIntents
import Foundation
import ActivityKit

@available(iOS 17, *)
struct EndSessionIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "End Session"
    static var isDiscoverable = false
    
    @available(iOS 26, *)
    static var supportedModes: IntentModes = .background

    @Parameter(title: "App Activity ID")
    var appActivityId: String
    
    @Parameter(title: "Live Activity ID")
    var liveActivityId: String

    init() {}
        
    init(liveActivityId: String, appActivityId: String) {
        self.liveActivityId = liveActivityId
        self.appActivityId = appActivityId
    }

    func perform() async -> some IntentResult {
        appendEndedActivity(appActivityId)
        
        let activities = LiveActivityManager.get.activities
        appendLog("Live Activities: \(activities.count)")
        
        // End live activity immediately. This gets around the delay from native-to-Flutter
        // to end live activities. It also handles the case where the app is no longer
        // running when the user ends the app activity.
        for activity in activities {
            guard activity.id == liveActivityId else {
                continue
            }
            appendLog("Ending live activity from app intent: \(activity.id)")
            await activity.end(
                ActivityContent(state: .init(), staleDate: nil),
                dismissalPolicy: .immediate
            )
        }
        
        return .result()
    }
}

@available(iOS 17, *)
extension EndSessionIntent {
    static var openAppWhenRun: Bool { false }
}
