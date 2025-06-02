//
//  sleepBreakdownApp.swift
//  sleepBreakdown
//
//  Created by Dzakiyyah Azahra on 29/05/25.
//

import SwiftUI
import SwiftData

@main
struct SleepBreakdownApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: SleepData.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            DailyView(modelContext: container.mainContext)
        }
        .modelContainer(container)
    }
}
