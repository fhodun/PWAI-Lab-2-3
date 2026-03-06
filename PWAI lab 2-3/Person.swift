//
//  Person.swift
//  PWAI lab 2-3
//
//  Created by Filip Hodun on 03/03/2026.
//

import Foundation
import SwiftData

@Model
final class Person {
    var first_name: String
    var last_name: String
    var birth_date: Date
    var city: String
    var timestamp: Date
    
    init(first_name:String, last_name:String, birth_date:Date, city:String, timestamp: Date) {
        self.first_name = first_name
        self.last_name = last_name
        self.birth_date = birth_date
        self.city = city
        self.timestamp = timestamp
    }
}
