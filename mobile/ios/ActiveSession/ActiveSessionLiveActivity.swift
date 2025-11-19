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
    let timerFontSize: CGFloat = 48.0
    let activityNameFontSize: CGFloat = 20.0
    let bgOpacity: CGFloat = 0.35
    let padding: CGFloat = 16.0
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            let model = Model(context: context)
            
            // The +'s here are a workaround for the timer text's automatic stretching to fill its container.
            // Details: https://stackoverflow.com/questions/66210592/widgetkit-timer-text-style-expands-it-to-fill-the-width-instead-of-taking-spa
            // Also, this is stashed in a variable because the .lineLimit and .truncationMode modifiers
            // used below do not work with Text "+" concatination.
            let timerNameText =
                Text(timerInterval: model.timerInterval, countsDown: false)
                    .font(.system(size: timerFontSize)) +
                Text("  ") +
                Text(model.name)
                    .font(.system(size: activityNameFontSize))
                    .foregroundStyle(.secondary)
            
            HStack(alignment: .center) {
                HStack(alignment: .bottom) {
                    timerNameText
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                Spacer()
                Button(intent: EndSessionIntent(liveActivityId: context.activityID, appActivityId: model.id)) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: timerFontSize / 2, weight: .bold))
                        .foregroundColor(.red)
                        .frame(width: timerFontSize, height: timerFontSize)
                        .background(Circle().fill(Color.red.opacity(bgOpacity)))
                }
                .buttonStyle(.plain)
                .tint(.clear)
            }
            .padding(padding)
            .activityBackgroundTint(model.bgTint)
        } dynamicIsland: { context in
            // TODO: Need to finish this UI.
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

@available(iOS 17, *)
struct Model {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    
    var timerInterval: ClosedRange<Date> {
        let sessionStart = defaults.integer(forKey: context.attributes.prefixedKey("session_start_timestamp"))
        let start = Date(timeIntervalSince1970: Double(sessionStart) / 1000)
        let end = Date(timeIntervalSince1970: 32503680000) // Year 3000.
        return start...end
    }
    
    var name: String {
        defaults.string(forKey: context.attributes.prefixedKey("activity_name"))!
    }
    
    var id: String {
        defaults.string(forKey: context.attributes.prefixedKey("activity_id"))!
    }
    
    var bgTint: Color {
        Color(
            red: defaults.double(forKey: context.attributes.prefixedKey("ios_bg_r")),
            green: defaults.double(forKey: context.attributes.prefixedKey("ios_bg_g")),
            blue: defaults.double(forKey: context.attributes.prefixedKey("ios_bg_b")),
            opacity: defaults.double(forKey: context.attributes.prefixedKey("ios_bg_a"))
        )
    }
}
