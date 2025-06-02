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
    @StateObject private var restednessViewModel: RestednessViewModel
    let container: ModelContainer
    
    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: SleepData.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        self.container = container
        self._restednessViewModel = StateObject(wrappedValue: RestednessViewModel(modelContext: container.mainContext))
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
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
                .task {
                    await restednessViewModel.checkDailyRestednessInput()
                }
                
                if restednessViewModel.showingRestednessInput {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    RestednessInputView(viewModel: restednessViewModel)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .modelContainer(container)
    }
}
