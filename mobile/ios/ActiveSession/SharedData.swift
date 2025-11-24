//
//  SharedData.swift
//  Runner
//
//  Created by Cohen Adair on 2025-10-14.
//

import Foundation
import WidgetKit

// Seems to be required at a global scope for the live activity to show up.
// Using a singleton didn't work as I expected it would.
let defaults = UserDefaults(suiteName: "group.cohenadair.activitylog")!
let keyEndedActivityIds = "ended_activity_ids"

func appendLog(_ log: String) {
    appendStringArray("logs", log)
}

func appendEndedActivity(_ activityId: String) {
    if (defaults.stringArray(forKey: keyEndedActivityIds) ?? []).contains(where: { $0.starts(with: activityId) }) {
        appendLog("Ended activity (\(activityId)) already exists in shared data")
        return
    }
    appendStringArray(keyEndedActivityIds, "\(activityId):\(Int(Date().timeIntervalSince1970 * 1000))")
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
