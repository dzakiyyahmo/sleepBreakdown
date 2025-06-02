import Foundation
import SwiftData
import HealthKit

@MainActor
class WeeklyViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager()
    private let modelContext: ModelContext
    
    @Published var weeklyData: [SleepData] = []
    @Published var currentWeekStart: Date
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.currentWeekStart = Calendar.current.startOfWeek(for: Date())
    }
    
    func moveToNextWeek() {
        currentWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) ?? currentWeekStart
        Task {
            await fetchWeeklyData()
        }
    }
    
    func moveToPreviousWeek() {
        currentWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart) ?? currentWeekStart
        Task {
            await fetchWeeklyData()
        }
    }
    
    func fetchWeeklyData() async {
        let calendar = Calendar.current
        let weekStart = calendar.startOfDay(for: currentWeekStart)
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        
        // First try to fetch from SwiftData
        let descriptor = FetchDescriptor<SleepData>(
            predicate: #Predicate<SleepData> { sleepData in
                sleepData.date >= weekStart && sleepData.date < weekEnd
            },
            sortBy: [SortDescriptor(\.date)]
        )
        
        do {
            let existingData = try modelContext.fetch(descriptor)
            
            // Get all dates in the week
            let weekDates = (0...6).compactMap { dayOffset in
                calendar.date(byAdding: .day, value: dayOffset, to: weekStart)
            }
            
            // Find dates that don't have data
            let missingDates = weekDates.filter { date in
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                return !existingData.contains { sleepData in
                    let sleepDate = calendar.startOfDay(for: sleepData.date)
                    return sleepDate >= startOfDay && sleepDate < endOfDay
                }
            }
            
            // Fetch missing data from HealthKit
            for date in missingDates {
                let (totalSleep,
                     remSleep,
                     coreSleep,
                     deepSleep,
                     awakeTime,
                     firstSleep,
                     lastSleep) = await healthKitManager.fetchSleepData(for: date)
                
                let sleepData = SleepData(date: date)
                sleepData.totalSleepDuration = totalSleep
                sleepData.remSleepDuration = remSleep
                sleepData.coreSleepDuration = coreSleep
                sleepData.deepSleepDuration = deepSleep
                sleepData.awakeDuration = awakeTime
                sleepData.sleepStart = firstSleep
                sleepData.sleepEnd = lastSleep
                
                modelContext.insert(sleepData)
            }
            
            if !missingDates.isEmpty {
                try modelContext.save()
            }
            
            // Fetch final complete dataset
            weeklyData = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching weekly data: \(error)")
        }
    }
    
    // MARK: - Weekly Statistics
    
    private var daysWithSleepData: [SleepData] {
        weeklyData.filter { $0.totalSleepDuration > 0 }
    }
    
    var averageSleepDuration: TimeInterval {
        let validData = daysWithSleepData
        guard !validData.isEmpty else { return 0 }
        let total = validData.reduce(0) { $0 + $1.totalSleepDuration }
        return total / Double(validData.count)
    }
    
    var totalSleepTime: TimeInterval {
        daysWithSleepData.reduce(0) { $0 + $1.totalSleepDuration }
    }
    
//    var averageDeepSleepPercentage: Double {
//        let validData = daysWithSleepData
//        guard !validData.isEmpty else { return 0 }
//        let percentages = validData.map { data in
//            data.totalSleepDuration > 0 ? (data.deepSleepDuration / data.totalSleepDuration) * 100 : 0
//        }
//        return percentages.reduce(0, +) / Double(validData.count)
//    }
    
    var averageCoreSleep: TimeInterval {
        let validData = daysWithSleepData
        guard !validData.isEmpty else { return 0 }
        let total = validData.reduce(0) { $0 + $1.coreSleepDuration }
        return total / Double(validData.count)
    }
    
    var averageRemSleep: TimeInterval {
        let validData = daysWithSleepData
        guard !validData.isEmpty else { return 0 }
        let total = validData.reduce(0) { $0 + $1.remSleepDuration }
        return total / Double(validData.count)
    }
    
    var averageDeepSleep: TimeInterval {
        let validData = daysWithSleepData
        guard !validData.isEmpty else { return 0 }
        let total = validData.reduce(0) { $0 + $1.deepSleepDuration }
        return total / Double(validData.count)
    }
    
    var averageAwakeTime: TimeInterval {
        let validData = daysWithSleepData
        guard !validData.isEmpty else { return 0 }
        let total = validData.reduce(0) { $0 + $1.awakeDuration }
        return total / Double(validData.count)
    }
    
    var daysWithSleepCount: Int {
        daysWithSleepData.count
    }
    
    func getFormattedDuration(for duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
    
    func getFormattedPercentage(for value: Double) -> String {
        String(format: "%.1f%%", value)
    }
} 


