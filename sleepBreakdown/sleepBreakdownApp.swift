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
            TabView {
                DailyView(modelContext: container.mainContext)
                    .tabItem {
                        Label("Daily", systemImage: "clock")
                    }
                
                WeeklyView(modelContext: container.mainContext)
                    .tabItem {
                        Label("Weekly", systemImage: "calendar")
                    }
                
                MonthlyView(modelContext: container.mainContext)
                    .tabItem {
                        Label("Monthly", systemImage: "calendar.badge.clock")
                    }
            }
        }
        .modelContainer(container)
    }
}
