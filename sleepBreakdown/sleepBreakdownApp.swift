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
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    init() {
        do {
            container = try ModelContainer(for: SleepData.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                // Use TabView for navigation
                TabView {
                   DailyView(modelContext: container.mainContext)
                        .tabItem {
                            Label("Daily", systemImage: "bed.double")
                        }
                    
                    // Use WeeklyView instead of a placeholder
                    WeeklyView(modelContext: container.mainContext)
                        .tabItem {
                            Label("Weekly", systemImage: "calendar")
                        }
                    
                    // Placeholder for MonthlyView
                    MonthlyView(modelContext: container.mainContext)
                        .tabItem {
                            Label("Monthly", systemImage: "calendar.badge.clock")
                        }
                }
            } else {
                OnboardingView(hasOnboarded: $hasOnboarded)
            }
            
        }
        .modelContainer(container)
    }
}
