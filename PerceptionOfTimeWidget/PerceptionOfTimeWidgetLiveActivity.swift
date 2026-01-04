//
//  PerceptionOfTimeWidgetLiveActivity.swift
//  PerceptionOfTimeWidget
//
//  Created by eray.alan on 7/30/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PerceptionOfTimeWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PerceptionOfTimeWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PerceptionOfTimeWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

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
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PerceptionOfTimeWidgetAttributes {
    fileprivate static var preview: PerceptionOfTimeWidgetAttributes {
        PerceptionOfTimeWidgetAttributes(name: "World")
    }
}

extension PerceptionOfTimeWidgetAttributes.ContentState {
    fileprivate static var smiley: PerceptionOfTimeWidgetAttributes.ContentState {
        PerceptionOfTimeWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PerceptionOfTimeWidgetAttributes.ContentState {
         PerceptionOfTimeWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PerceptionOfTimeWidgetAttributes.preview) {
   PerceptionOfTimeWidgetLiveActivity()
} contentStates: {
    PerceptionOfTimeWidgetAttributes.ContentState.smiley
    PerceptionOfTimeWidgetAttributes.ContentState.starEyes
}
