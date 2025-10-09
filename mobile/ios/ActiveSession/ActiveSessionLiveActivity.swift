//
//  ActiveSessionLiveActivity.swift
//  ActiveSession
//
//  Created by Cohen Adair on 2025-10-09.
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

// TODO: Seems to be required at a global scope for the live activity to show up.
// Using a singleton didn't work. May require more investigation.
private let defaults = UserDefaults(suiteName: "group.cohenadair.activitylog")!

// TODO: Needs methods for accessing all fields set in LiveActivityManager._onSessionStarted().
// These fields should be utilized when creating the live activity UI.

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable { }

    var id = UUID()
}

struct ActiveSessionLiveActivity: Widget {
    // TODO: Finish UI.
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            HStack {
                Text("Activity Name")
                Spacer()
                if #available(iOS 17, *) {
                    Button(intent: EndSessionIntent("TODO: Get ID from defaults")) {
                        Text("STOP")
                    }
                } else {
                    // Note that this opens the app (no way around it for iOS 16-).
                    Link(destination: URL(string: "")!) {
                        Text("STOP")
                    }
                }
            }
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("M")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    return "\(id)_\(key)"
  }
}
