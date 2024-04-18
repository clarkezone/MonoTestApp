//
//  Item.swift
//  MonoTestApp
//
//  Created by James Clarke on 11/6/23.
//

import Foundation
import SwiftData

@Model
final class AppSettings {
    var queryendpointurl: String?
    
    init(url: String?) {
        self.queryendpointurl = url
    }
}

@Model
final class CounterData {
    var lastupdated: Date?
    var count: Int64?
    var counterstate: Bool?
    
    init(lastupdate: Date?, count: Int64?, counterstate: Bool?) {
        self.lastupdated = lastupdate
        self.count = count
        self.counterstate = counterstate
    }
}

@Model
final class Item {
    var timestamp: Date?
    var name: String?
    
    init(timestamp: Date?, name: String?) {
        self.timestamp = timestamp
        self.name = name
    }
}
