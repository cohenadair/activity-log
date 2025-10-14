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

@available(iOS 17, *)
struct ActiveSessionLiveActivity: Widget {
    // TODO: Finish UI.
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            HStack {
                Text("Activity Name")
                Spacer()
                Button(intent: EndSessionIntent(liveActivityId: context.activityID, appActivityId: activityId(context))) {
                    Text("STOP")
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
