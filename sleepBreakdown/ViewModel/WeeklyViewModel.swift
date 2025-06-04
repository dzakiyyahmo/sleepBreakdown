import Foundation
import SwiftData
import HealthKit
import CoreML

@MainActor
class WeeklyViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager()
    let modelContext: ModelContext
    private var predictionService: RestednessPredictionService? // Remains optional
    
    @Published var weeklyData: [SleepData] = [] // Data for the charts and daily breakdown (the week currently viewed)
    @Published var currentWeekStart: Date // The start date of the week currently being viewed
    
    // RENAMED: This is the single prediction you want to display for the next week
    @Published var predictedRestednessForNextWeek: Double?
    
    @Published var predictionErrorMessage: String? // General error message for data loading/prediction
    
    var orbPreset: OrbPreset {
        let hoursOfSleep = averageSleepDuration / 3600
        switch hoursOfSleep {
        case 8...:
            return .ocean
        case 5..<8:
            return .cosmic
        default:
            return .sunset
        }
    }
    
    var averageRestednessScore: Double {
        // If RestednessViewModel.checkDailyRestednessInput still uses '0' as "not set",
        // then those '0's might skew the average if not filtered.
        // Assuming for now that scores in weeklyData are actual user inputs (-1 to 1).
        // If '0' can mean "not set by user yet", you'd need to filter those out.
        // For example, if you adopt SleepData.restednessScore: Double?
        // let validScores = weeklyData.compactMap { $0.restednessScore }
        // guard !validScores.isEmpty else { return 0 } // or some other indicator for N/A
        // let totalScore = validScores.reduce(0, +)
        // return totalScore / Double(validScores.count)
        
        // Current implementation, assuming all scores in weeklyData are valid (or 0 is a valid avg starting point):
        guard !weeklyData.isEmpty else { return 0 }
        let totalScore = weeklyData.reduce(0) { $0 + $1.restednessScore }
        return totalScore / Double(weeklyData.count) // This will average values between -1 and 1.
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.currentWeekStart = Calendar.current.startOfWeek(for: Date()) // Start with current week
        
        do {
            self.predictionService = try RestednessPredictionService()
            self.predictionErrorMessage = nil // Clear any previous errors on successful service init
        } catch {
            print("Failed to initialize RestednessPredictionService: \(error.localizedDescription)")
            self.predictionService = nil // If service fails to init, it's nil
            self.predictionErrorMessage = "Prediction model unavailable: \(error.localizedDescription)"
        }
    }
    
    // RENAMED AND MODIFIED: This function now calculates the prediction for the *next week* based on *passed data*
    private func calculatePredictedRestednessForNextWeek(basedOn dataForPrediction: [SleepData]) {
        guard let predictionService = predictionService else {
            predictedRestednessForNextWeek = nil
            predictionErrorMessage = "Prediction service not available."
            return
        }
        
        var dailyPredictions: [Double] = []
        // Only consider sleep entries that actually have some duration for prediction
        for sleepEntry in dataForPrediction where sleepEntry.totalSleepDuration > 0 { // <-- Uses passed dataForPrediction
            do {
                let prediction = try predictionService.predictRestedness(
                    awake: sleepEntry.awakeDuration,
                    core: sleepEntry.coreSleepDuration,
                    deep: sleepEntry.deepSleepDuration,
                    rem: sleepEntry.remSleepDuration,
                    unspecified: sleepEntry.unspecifiedSleepDuration, // Use the stored value directly
                    totalSleepDuration: sleepEntry.totalSleepDuration
                )
                dailyPredictions.append(prediction)
            } catch {
                print("Error predicting restedness for \(sleepEntry.date) in previous week: \(error.localizedDescription)")
            }
        }
        
        if !dailyPredictions.isEmpty {
            let averagePrediction = dailyPredictions.reduce(0, +) / Double(dailyPredictions.count)
            predictedRestednessForNextWeek = averagePrediction // <-- Updates the correct @Published property
            // predictionErrorMessage is handled at the fetch level
        } else {
            predictedRestednessForNextWeek = nil
            predictionErrorMessage = "Not enough data from previous week to make a prediction."
        }
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
        
        // --- 1. Define date range for the CURRENTLY VIEWED week (for UI display) ---
        let currentWeekDisplayStart = calendar.startOfDay(for: currentWeekStart)
        let currentWeekDisplayEnd = calendar.date(byAdding: DateComponents(day: 7, second: -1), to: currentWeekDisplayStart)!
        
        // --- 2. Define date range for the PREVIOUS week (for ML model input) ---
        guard let previousWeekPredictionStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart) else {
            print("Could not determine previous week start date for prediction.")
            predictionErrorMessage = "Error determining week range for prediction."
            predictedRestednessForNextWeek = nil
            weeklyData = [] // Clear current week data if date calculation fails
            return
        }
        let previousWeekPredictionEnd = calendar.date(byAdding: DateComponents(day: 7, second: -1), to: previousWeekPredictionStart)!
        
        
        // --- Fetch CURRENT week data from SwiftData ---
        let currentWeekDescriptor = FetchDescriptor<SleepData>(
            predicate: #Predicate<SleepData> { sleepData in
                sleepData.date >= currentWeekDisplayStart && sleepData.date <= currentWeekDisplayEnd
            },
            sortBy: [SortDescriptor(\.date)]
        )
        
        // --- Fetch PREVIOUS week data from SwiftData ---
        let previousWeekDescriptor = FetchDescriptor<SleepData>(
            predicate: #Predicate<SleepData> { sleepData in
                sleepData.date >= previousWeekPredictionStart && sleepData.date <= previousWeekPredictionEnd
            },
            sortBy: [SortDescriptor(\.date)]
        )
        
        do {
            let existingCurrentWeekData = try modelContext.fetch(currentWeekDescriptor)
            let existingPreviousWeekData = try modelContext.fetch(previousWeekDescriptor)
            
            // --- HealthKit Synchronization ---
            // Identify all unique dates that might need fetching (from both current and previous weeks)
            var allRelevantDatesForSync: Set<Date> = Set()
            existingCurrentWeekData.forEach { allRelevantDatesForSync.insert(calendar.startOfDay(for: $0.date)) }
            existingPreviousWeekData.forEach { allRelevantDatesForSync.insert(calendar.startOfDay(for: $0.date)) }
            
            let datesToCover = weekDates(from: currentWeekDisplayStart, count: 7) + weekDates(from: previousWeekPredictionStart, count: 7)
            
            let missingDatesToFetch = datesToCover.filter { date in
                !allRelevantDatesForSync.contains(calendar.startOfDay(for: date))
            }
            
            // Fetch missing data from HealthKit and insert into SwiftData
            for date in missingDatesToFetch {
                // Assuming your HealthKitManager's fetchSleepData now returns unspecifiedSleep as well
                let (totalSleep, remSleep, coreSleep, deepSleep, unspecifiedSleep, awakeTime, firstSleep, lastSleep) = await healthKitManager.fetchSleepData(for: date)
                
                let sleepData = SleepData(
                    date: date,
                    totalSleepDuration: totalSleep,
                    remSleepDuration: remSleep,
                    coreSleepDuration: coreSleep,
                    deepSleepDuration: deepSleep,
                    awakeDuration: awakeTime,
                    unspecifiedSleepDuration: unspecifiedSleep,
                    sleepStart: firstSleep,
                    sleepEnd: lastSleep,
                    restednessScore: 0,
                    notes: ""
                )
                modelContext.insert(sleepData)
            }
            
            if !missingDatesToFetch.isEmpty {
                try modelContext.save()
            }
            
            // --- Update ViewModel properties after all data is potentially refreshed ---
            self.weeklyData = try modelContext.fetch(currentWeekDescriptor) // Set current week's data for UI
            let dataForPrediction = try modelContext.fetch(previousWeekDescriptor) // Get previous week's data for ML
            
            self.predictionErrorMessage = nil // Clear any previous errors
            
            // --- Call the prediction function with the PREVIOUS week's data ---
            calculatePredictedRestednessForNextWeek(basedOn: dataForPrediction)
            
        } catch {
            print("Error fetching weekly data or previous week data: \(error.localizedDescription)")
            self.predictionErrorMessage = "Failed to load sleep data: \(error.localizedDescription)"
            self.weeklyData = [] // Clear data if there's an error
            self.predictedRestednessForNextWeek = nil
        }
    }
    
    // Helper to generate a range of dates
    private func weekDates(from startDate: Date, count: Int) -> [Date] {
        let calendar = Calendar.current
        return (0..<count).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startDate)
        }
    }
    
    // MARK: - Weekly Statistics (these still use `weeklyData`, which is the current week's data)
    // ... (Your existing statistic computed properties and formatter functions remain unchanged) ...
    
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
    var averageUnspecifiedSleep: TimeInterval{
        let validData = daysWithSleepData
        guard !validData.isEmpty else { return 0 }
        let total = validData.reduce(0) { $0 + $1.unspecifiedSleepDuration}
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
    
    func getFormattedRestednessPercentage(for score: Double) -> String { // score is an average of -1 to 1 values
        // Convert score from -1 to 1 range to 0-100% range
        let clampedScore = max(-1.0, min(1.0, score)) // Clamp average in case of any floating point oddities
        let percentage = ((clampedScore + 1) / 2) * 100
        return String(format: "%.0f%%", percentage)
    }
}


