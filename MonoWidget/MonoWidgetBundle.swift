//
//  MonoWidgetBundle.swift
//  MonoWidget
//
//  Created by James Clarke on 11/19/23.
//

import WidgetKit
import SwiftUI

@main
struct MonoWidgetBundle: WidgetBundle {
    var body: some Widget {
        MonoWidget()
        MonoWidgetLiveActivity()
    }
}
