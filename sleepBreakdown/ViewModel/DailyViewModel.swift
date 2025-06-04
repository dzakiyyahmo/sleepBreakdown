import Foundation
import HealthKit
import SwiftData
import CoreML

@MainActor
class DailyViewModel: ObservableObject {
    private let healthKitManager = HealthKitManager()
    private let modelContext: ModelContext
    private var predictionService: RestednessPredictionService?
    
    @Published var currentDate: Date = Date()
    @Published var sleepData: SleepData?
    @Published var predictedRestednessForTomorrow: Double? // Stores the ML prediction result
    @Published var dailyPredictionErrorMessage: String? // Stores ML-specific error messages
    
    var orbPreset: OrbPreset {
        let hoursOfSleep = (sleepData?.totalSleepDuration ?? 0) / 3600
        switch hoursOfSleep {
        case 8...:
            return .ocean
        case 5..<8:
            return .cosmic
        default:
            return .sunset
        }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        do {
            self.predictionService = try RestednessPredictionService()
            self.dailyPredictionErrorMessage = nil
        } catch {
            print("Failed to initialize RestednessPredictionService in DailyViewModel: \(error.localizedDescription)")
            self.predictionService = nil
            self.dailyPredictionErrorMessage = "Prediction model unavailable: \(error.localizedDescription)"
        }
    }
    
    func calculatePredictedRestednessForTomorrow(basedOn todaySleepData: SleepData?) {
        guard let predictionService = predictionService else {
            predictedRestednessForTomorrow = nil
            dailyPredictionErrorMessage = "Prediction service not available."
            return
        }
        
        guard let sleepEntry = todaySleepData, sleepEntry.totalSleepDuration > 0 else {
            predictedRestednessForTomorrow = nil
            dailyPredictionErrorMessage = "Not enough valid sleep data for today to make a prediction for tomorrow."
            return
        }
        
        do {
            let prediction = try predictionService.predictRestedness(
                awake: sleepEntry.awakeDuration,
                core: sleepEntry.coreSleepDuration,
                deep: sleepEntry.deepSleepDuration,
                rem: sleepEntry.remSleepDuration,
                unspecified: sleepEntry.unspecifiedSleepDuration,
                totalSleepDuration: sleepEntry.totalSleepDuration
            )
            predictedRestednessForTomorrow = prediction
            dailyPredictionErrorMessage = nil
        } catch {
            print("Error predicting restedness for tomorrow based on today's sleep: \(error.localizedDescription)")
            predictedRestednessForTomorrow = nil
            dailyPredictionErrorMessage = "Failed to predict restedness for tomorrow: \(error.localizedDescription)"
        }
    }
    
    func moveToNextDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        fetchSleepData() // This will now correctly trigger the prediction
    }
    
    func moveToPreviousDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        fetchSleepData() // This will now correctly trigger the prediction
    }
    
    func fetchSleepData() {
        // We need to fetch stored data first, then HealthKit.
        // The ML prediction logic should only run after HealthKit data is fetched/updated,
        // because that's when `self.sleepData` will contain the most accurate and recent data.
        
        // This is necessary to potentially update `self.sleepData` from SwiftData quickly
        fetchStoredData()
        
        Task {
            // Await the HealthKit fetch to ensure `self.sleepData` is fully up-to-date
            await requestAndFetchFromHealthKit()
            
            // Now that `self.sleepData` is updated, perform the prediction logic
            self.performPredictionIfNeeded()
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
             unspecifiedSleep,
             awakeTime,
             firstSleep,
             lastSleep) = await healthKitManager.fetchSleepData(for: currentDate)
        
        // Create or update SleepData in SwiftData
        let sleepDataToSave: SleepData
        if let existingSleepData = self.sleepData {
            sleepDataToSave = existingSleepData
        } else {
            sleepDataToSave = SleepData(date: currentDate)
            modelContext.insert(sleepDataToSave)
        }
        
        sleepDataToSave.totalSleepDuration = totalSleep
        sleepDataToSave.remSleepDuration = remSleep
        sleepDataToSave.coreSleepDuration = coreSleep
        sleepDataToSave.deepSleepDuration = deepSleep
        sleepDataToSave.unspecifiedSleepDuration = unspecifiedSleep
        sleepDataToSave.awakeDuration = awakeTime
        sleepDataToSave.sleepStart = firstSleep
        sleepDataToSave.sleepEnd = lastSleep
        
        self.sleepData = sleepDataToSave // Crucially update the published property
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving sleep data: \(error)")
        }
    }
    
    private func performPredictionIfNeeded() {
        let calendar = Calendar.current
        if calendar.isDateInToday(currentDate) {
            calculatePredictedRestednessForTomorrow(basedOn: sleepData)
        } else {
            predictedRestednessForTomorrow = nil
            dailyPredictionErrorMessage = nil
        }
    }
    
    func getFormattedDuration(for duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
    
    func getFormattedRestedness(score: Double) -> String {
            // Convert score from -1 to 1 range to 0-100% range
            // Ensure score is clamped to -1 to 1 if it could ever be outside, though slider prevents this.
            let clampedScore = max(-1.0, min(1.0, score))
            let percentage = ((clampedScore + 1) / 2) * 100
            return String(format: "%.0f%%", percentage)
        }
}
