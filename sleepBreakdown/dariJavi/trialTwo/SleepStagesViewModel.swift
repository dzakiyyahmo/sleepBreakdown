import Foundation
import HealthKit

class SleepStagesViewModel: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var totalSleepDuration: TimeInterval = 0
    @Published var remSleepDuration: TimeInterval = 0
    @Published var coreSleepDuration: TimeInterval = 0
    @Published var deepSleepDuration: TimeInterval = 0
    @Published var awakeDuration: TimeInterval = 0
    @Published var sleepStart: Date?
    @Published var sleepEnd: Date?

    
    
    func requestAndFetch(for date: Date) {
        // 1. Guard: Check requirements first
        guard HKHealthStore.isHealthDataAvailable(),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { 
            // If requirements not met, exit
            return 
        }
        
        // 2. Request authorization with closure
        healthStore.requestAuthorization(toShare: [], read: [sleepType]) { [weak self] success, _ in
            // This code runs later, after authorization is complete
            
            if success {
                // 3. If successful and self still exists, fetch sleep data
                self?.fetchSleepStages(for: date)
            }
        }
    }
    
    private func fetchSleepStages(for date: Date) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let calendar = Calendar.current
        
        // For a given date, we want to look at sleep from previous day 6 PM to current day 12 PM
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date)!
        let previousDay = calendar.date(byAdding: .day, value: -1, to: date)!
        let previousDayEvening = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: previousDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: previousDayEvening, end: noon, options: [])
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 0, sortDescriptors: nil) { [weak self] _, results, error in
            guard let samples = results as? [HKCategorySample], error == nil else { return }
            
            // Filter samples that fall within our time window
            let validSamples = samples.filter {
                $0.endDate > previousDayEvening && $0.startDate < noon
            }.sorted { $0.startDate < $1.startDate }
            
            // Initialize duration trackers
            var totalSleep: TimeInterval = 0
            var remSleep: TimeInterval = 0
            var coreSleep: TimeInterval = 0
            var deepSleep: TimeInterval = 0
            var awakeTime: TimeInterval = 0
            
            // Find first and last sleep times
            var firstSleep: Date?
            var lastSleep: Date?
            
            for sample in validSamples {
                let duration = sample.endDate.timeIntervalSince(sample.startDate)
                
                // Only count segments that are at least 1 minute long
                guard duration >= 60 else { continue }
                
                switch sample.value {
                case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                    remSleep += duration
                    totalSleep += duration
                    if firstSleep == nil { firstSleep = sample.startDate }
                    lastSleep = sample.endDate
                    
                case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                    coreSleep += duration
                    totalSleep += duration
                    if firstSleep == nil { firstSleep = sample.startDate }
                    lastSleep = sample.endDate
                    
                case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                    deepSleep += duration
                    totalSleep += duration
                    if firstSleep == nil { firstSleep = sample.startDate }
                    lastSleep = sample.endDate
                    
                case HKCategoryValueSleepAnalysis.awake.rawValue:
                    // Only count awake time if it's between sleep segments
                    if firstSleep != nil {
                        awakeTime += duration
                    }
                    
                default:
                    break
                }
            }
    
            DispatchQueue.main.async {
                self?.totalSleepDuration = totalSleep
                self?.remSleepDuration = remSleep
                self?.coreSleepDuration = coreSleep
                self?.deepSleepDuration = deepSleep
                self?.awakeDuration = awakeTime
                self?.sleepStart = firstSleep
                self?.sleepEnd = lastSleep
            }
        }
        
        healthStore.execute(query)
    }
    
    // Helper function to get formatted duration string
    func getFormattedDuration(for duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
} 
