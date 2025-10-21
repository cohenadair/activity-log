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
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            let model = Model(context: context)
            
            HStack(alignment: .center) {
                HStack(alignment: .bottom) {
                    // The +'s here are a workaround for the timer text's automatic stretching to fill its container.
                    // Details: https://stackoverflow.com/questions/66210592/widgetkit-timer-text-style-expands-it-to-fill-the-width-instead-of-taking-spa
                    Text(timerInterval: model.timerInterval, countsDown: false)
                        .font(.system(size: model.timerFontSize)) +
                    Text("  ") +
                    Text(model.name)
                        .font(.system(size: model.activityNameFontSize))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(intent: EndSessionIntent(liveActivityId: context.activityID, appActivityId: model.id)) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: model.timerFontSize / 2, weight: .bold))
                        .foregroundColor(.red)
                        .frame(width: model.timerFontSize, height: model.timerFontSize)
                        .background(Circle().fill(Color.red.opacity(model.stopBgOpacity)))
                }
                .buttonStyle(.plain)
                .tint(.clear)
            }
            .padding(model.padding)
            .activityBackgroundTint(model.bgTint)
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
            red: defaults.double(forKey: context.attributes.prefixedKey("bg_r")),
            green: defaults.double(forKey: context.attributes.prefixedKey("bg_g")),
            blue: defaults.double(forKey: context.attributes.prefixedKey("bg_b")),
            opacity: defaults.double(forKey: context.attributes.prefixedKey("bg_a"))
        )
    }
    
    var stopBgOpacity: Double {
        defaults.double(forKey: context.attributes.prefixedKey("stop_bg_opacity"))
    }
    
    var timerFontSize: Double {
        defaults.double(forKey: context.attributes.prefixedKey("timer_font_size"))
    }
    
    var activityNameFontSize: Double {
        defaults.double(forKey: context.attributes.prefixedKey("activity_name_font_size"))
    }
    
    var padding: Double {
        defaults.double(forKey: context.attributes.prefixedKey("padding"))
    }
}
