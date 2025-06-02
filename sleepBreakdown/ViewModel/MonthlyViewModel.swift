import Foundation
import SwiftData
import HealthKit

@MainActor
class MonthlyViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager()
    private let modelContext: ModelContext
    
    @Published var monthlyData: [SleepData] = []
    @Published var currentMonthStart: Date
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.currentMonthStart = Calendar.current.startOfMonth(for: Date())
    }
    
    func moveToNextMonth() {
        currentMonthStart = Calendar.current.date(byAdding: .month, value: 1, to: currentMonthStart) ?? currentMonthStart
        Task {
            await fetchMonthlyData()
        }
    }
    
    func moveToPreviousMonth() {
        currentMonthStart = Calendar.current.date(byAdding: .month, value: -1, to: currentMonthStart) ?? currentMonthStart
        Task {
            await fetchMonthlyData()
        }
    }
    
    func fetchMonthlyData() async {
        let calendar = Calendar.current
        let monthStart = calendar.startOfDay(for: currentMonthStart)
        let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
        let endOfLastDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: monthEnd)!
        
        // First try to fetch from SwiftData
        let descriptor = FetchDescriptor<SleepData>(
            predicate: #Predicate<SleepData> { sleepData in
                sleepData.date >= monthStart && sleepData.date <= endOfLastDay
            },
            sortBy: [SortDescriptor(\.date)]
        )
        
        do {
            let existingData = try modelContext.fetch(descriptor)
            
            // Get all dates in the month
            let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
            let monthDates = (0..<daysInMonth).compactMap { dayOffset in
                calendar.date(byAdding: .day, value: dayOffset, to: monthStart)
            }
            
            // Find dates that don't have data
            let missingDates = monthDates.filter { date in
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
            monthlyData = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching monthly data: \(error)")
        }
    }
    
    // MARK: - Monthly Statistics
    
    private var daysWithSleepData: [SleepData] {
        monthlyData.filter { $0.totalSleepDuration > 0 }
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
