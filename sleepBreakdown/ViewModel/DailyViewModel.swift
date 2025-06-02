import Foundation
import HealthKit
import SwiftData

@MainActor
class DailyViewModel: ObservableObject {
    private let healthStore = HKHealthStore()
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
        requestAndFetchFromHealthKit()
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
    
    private func requestAndFetchFromHealthKit() {
        guard HKHealthStore.isHealthDataAvailable(),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        healthStore.requestAuthorization(toShare: [], read: [sleepType]) { [weak self] success, _ in
            if success {
                Task { @MainActor [weak self] in
                    await self?.fetchSleepStages()
                }
            }
        }
    }
    
    private func fetchSleepStages() async {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let calendar = Calendar.current
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: currentDate)!
        let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        let previousDayEvening = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: previousDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: previousDayEvening, end: noon, options: [])
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 0, sortDescriptors: nil) { [weak self] _, results, error in
                guard let samples = results as? [HKCategorySample], error == nil else {
                    continuation.resume()
                    return
                }
                
                let validSamples = samples.filter {
                    $0.endDate > previousDayEvening && $0.startDate < noon
                }.sorted { $0.startDate < $1.startDate }
                
                var totalSleep: TimeInterval = 0
                var remSleep: TimeInterval = 0
                var coreSleep: TimeInterval = 0
                var deepSleep: TimeInterval = 0
                var awakeTime: TimeInterval = 0
                
                var firstSleep: Date?
                var lastSleep: Date?
                
                for sample in validSamples {
                    let duration = sample.endDate.timeIntervalSince(sample.startDate)
                    
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
                        if firstSleep != nil {
                            awakeTime += duration
                        }
                        
                    default:
                        break
                    }
                }
                
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    // Create or update SleepData in SwiftData
                    let sleepData = self.sleepData ?? SleepData(date: self.currentDate)
                    sleepData.totalSleepDuration = totalSleep
                    sleepData.remSleepDuration = remSleep
                    sleepData.coreSleepDuration = coreSleep
                    sleepData.deepSleepDuration = deepSleep
                    sleepData.awakeDuration = awakeTime
                    sleepData.sleepStart = firstSleep
                    sleepData.sleepEnd = lastSleep
                    
                    if self.sleepData == nil {
                        self.modelContext.insert(sleepData)
                    }
                    
                    self.sleepData = sleepData
                    
                    do {
                        try self.modelContext.save()
                    } catch {
                        print("Error saving sleep data: \(error)")
                    }
                    
                    continuation.resume()
                }
            }
            
            self.healthStore.execute(query)
        }
    }
    
    func getFormattedDuration(for duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
} 
