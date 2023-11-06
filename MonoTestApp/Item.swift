//
//  Item.swift
//  MonoTestApp
//
//  Created by James Clarke on 11/6/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
