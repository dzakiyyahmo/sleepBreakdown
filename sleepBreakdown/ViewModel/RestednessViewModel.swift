import SwiftUI
import SwiftData

@MainActor
class RestednessViewModel: ObservableObject {
    private let modelContext: ModelContext
    @Published var showingRestednessInput = false
    @Published var currentSleepData: SleepData?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func checkDailyRestednessInput() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // Fetch today's sleep data
        let descriptor = FetchDescriptor<SleepData>(
            predicate: #Predicate<SleepData> { sleepData in
                sleepData.date >= today && sleepData.date < tomorrow
            }
        )
        
        do {
            let todaysSleepData = try modelContext.fetch(descriptor)
            
            // If we have sleep data for today but no restedness score
            if let latestSleep = todaysSleepData.first, latestSleep.restednessScore == 0 {
                currentSleepData = latestSleep
                showingRestednessInput = true
            }
        } catch {
            print("Error fetching sleep data: \(error)")
        }
    }
    
    func saveRestednessScore(_ score: Double) {
        if let sleepData = currentSleepData {
            sleepData.restednessScore = score
            try? modelContext.save()
            showingRestednessInput = false
        }
    }
} 
