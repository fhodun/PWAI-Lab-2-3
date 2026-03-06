//
//  PWAI_lab_2_3App.swift
//  PWAI lab 2-3
//
//  Created by Filip Hodun on 03/03/2026.
//

import SwiftUI
import SwiftData

@main
struct PWAI_lab_2_3App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Person.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
