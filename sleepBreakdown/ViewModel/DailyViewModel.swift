import Foundation
import HealthKit
import SwiftData

@MainActor
class DailyViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager()
    private let modelContext: ModelContext
    
    @Published var currentDate: Date = Date()
    @Published var sleepData: SleepData?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func moveToNextDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        fetchSleepData()
    }
    
    func moveToPreviousDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        fetchSleepData()
    }
    
    func fetchSleepData() {
        // First try to fetch from SwiftData
        fetchStoredData()
        
        // Then fetch from HealthKit to ensure data is up to date
        Task {
            await requestAndFetchFromHealthKit()
        }
    }
    
    private func fetchStoredData() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<SleepData> { sleepData in
            sleepData.date >= startOfDay && sleepData.date < endOfDay
        }
        
        let descriptor = FetchDescriptor<SleepData>(predicate: predicate)
        
        do {
            let results = try modelContext.fetch(descriptor)
            self.sleepData = results.first
        } catch {
            print("Error fetching stored sleep data: \(error)")
        }
    }
    
    private func requestAndFetchFromHealthKit() async {
        guard await healthKitManager.requestAuthorization() else { return }
        
        let (totalSleep,
             remSleep,
             coreSleep,
             deepSleep,
             awakeTime,
             firstSleep,
             lastSleep) = await healthKitManager.fetchSleepData(for: currentDate)
        
        // Create or update SleepData in SwiftData
        let sleepData = self.sleepData ?? SleepData(date: currentDate)
        sleepData.totalSleepDuration = totalSleep
        sleepData.remSleepDuration = remSleep
        sleepData.coreSleepDuration = coreSleep
        sleepData.deepSleepDuration = deepSleep
        sleepData.awakeDuration = awakeTime
        sleepData.sleepStart = firstSleep
        sleepData.sleepEnd = lastSleep
        
        if self.sleepData == nil {
            modelContext.insert(sleepData)
        }
        
        self.sleepData = sleepData
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving sleep data: \(error)")
        }
    }
    
    func getFormattedDuration(for duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
} 
