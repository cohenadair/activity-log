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
    let stopButtonOpacity: CGFloat = 0.35
    let padding: CGFloat = 16.0
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            let model = Model(context: context)
            mainView(model, context)
                .padding(padding)
                .activityBackgroundTint(model.tintColorWithOpacity)
        } dynamicIsland: { context in
            let model = Model(context: context)
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    appIcon(model)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    mainView(
                        model,
                        context,
                        // Hardcoded padding value shouldn't be changed. It's there so the
                        // text horizontally aligns with the default padding added to the
                        // leading icon.
                        timerPadding: EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0)
                    )
                }
            } compactLeading: {
                appIcon(model)
            } compactTrailing: {
                // Using a hidden Text + overlay is a workaround to keep the timer's
                // width as small as possible (but still expandable) due to the default
                // behaviour of expanding timers to fit their container. This prevents
                // the Dynamic Island from unnecessarily taking up the entire screen's
                // width.
                Text("8:88:88")
                    .monospacedDigit()
                    .hidden()
                    .overlay {
                        Text(timerInterval: model.timerInterval, countsDown: false)
                            .monospacedDigit()
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(model.tintColor)
                    }
            } minimal: {
                appIcon(model)
            }
        }
    }
    
    private func mainView(
        _ model: Model,
        _ context: ActivityViewContext<LiveActivitiesAppAttributes>,
        timerPadding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    ) -> some View {
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
        
        return HStack(alignment: .center) {
            HStack(alignment: .bottom) {
                timerNameText
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(timerPadding)
            }
            Spacer()
            Button(intent: EndSessionIntent(liveActivityId: context.activityID, appActivityId: model.id)) {
                Image(systemName: "stop.fill")
                    .font(.system(size: timerFontSize / 2, weight: .bold))
                    .foregroundColor(.red)
                    .frame(width: timerFontSize, height: timerFontSize)
                    .background(Circle().fill(Color.red.opacity(stopButtonOpacity)))
            }
            .buttonStyle(.plain)
            .tint(.clear)
        }
    }
    
    private func appIcon(_ model: Model) -> some View {
        Image("AppIconBlack")
            .resizable()
            .scaledToFit()
            .foregroundStyle(model.tintColor)
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
    
    var tintColorWithOpacity: Color {
        tintColor.opacity(defaults.double(forKey: context.attributes.prefixedKey("tint_a")))
    }
    
    var tintColor: Color {
        Color(
            red: defaults.double(forKey: context.attributes.prefixedKey("tint_r")),
            green: defaults.double(forKey: context.attributes.prefixedKey("tint_g")),
            blue: defaults.double(forKey: context.attributes.prefixedKey("tint_b")),
        )
    }
}
