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
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Activity ID")
    var activityId: String

    init() {}
        
    init(_ activityId: String) {
        self.activityId = activityId
    }

    func perform() async -> some IntentResult {
        // TODO: Write to group data in format expected by LiveActivitiesManager._endActivitiesFromIosGroupData().
        
        // TODO: This doesn't work. Presumably because this class isn't part of the Runner target.
        // See https://github.com/praveeniroh/LiveActivity for an example of how to get this to
        // work, including updating the live activity UI from an intent.
        for activity in Activity<LiveActivitiesAppAttributes>.activities {
            guard activity.id == activityId else {
                continue
            }
            await activity.end(
                ActivityContent(state: .init(), staleDate: nil),
                dismissalPolicy: .immediate
            )
        }
        
        return .result()
    }
}
