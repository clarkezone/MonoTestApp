//
//  MonoWidgetLiveActivity.swift
//  MonoWidget
//
//  Created by James Clarke on 11/19/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MonoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MonoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MonoWidgetAttributes.self) { context in
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

extension MonoWidgetAttributes {
    fileprivate static var preview: MonoWidgetAttributes {
        MonoWidgetAttributes(name: "World")
    }
}

extension MonoWidgetAttributes.ContentState {
    fileprivate static var smiley: MonoWidgetAttributes.ContentState {
        MonoWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MonoWidgetAttributes.ContentState {
         MonoWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MonoWidgetAttributes.preview) {
   MonoWidgetLiveActivity()
} contentStates: {
    MonoWidgetAttributes.ContentState.smiley
    MonoWidgetAttributes.ContentState.starEyes
}
