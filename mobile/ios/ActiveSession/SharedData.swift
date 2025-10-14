//
//  SharedData.swift
//  Runner
//
//  Created by Cohen Adair on 2025-10-14.
//

import Foundation
import WidgetKit

// TODO: Seems to be required at a global scope for the live activity to show up.
// Using a singleton didn't work. May require more investigation.
let defaults = UserDefaults(suiteName: "group.cohenadair.activitylog")!

// TODO: Needs methods for accessing all fields set in LiveActivityManager._onSessionStarted().
// These fields should be utilized when creating the live activity UI.

@available(iOS 16.1, *)
func activityId(_ context: ActivityViewContext<LiveActivitiesAppAttributes>) -> String {
    return defaults.string(forKey: context.attributes.prefixedKey("activity_id"))!
}

func appendLog(_ log: String) {
    appendStringArray("logs", log)
}

func appendEndedActivity(_ activityId: String) {
    appendStringArray("ended_activity_ids", "\(activityId):\(Int(Date().timeIntervalSince1970 * 1000))")
}

private func appendStringArray(_ key: String, _ value: String) {
    var current = defaults.stringArray(forKey: key) ?? []
    current.append(value)
    defaults.set(current, forKey: key)
}

extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    return "\(id)_\(key)"
  }
}
