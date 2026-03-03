//
//  Item.swift
//  PWAI lab 2-3
//
//  Created by Filip Hodun on 03/03/2026.
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
