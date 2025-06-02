import Foundation
import HealthKit

class HealthKitManager {
    private let healthStore = HKHealthStore()
    
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable(),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return false
        }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [sleepType])
            return true
        } catch {
            print("Error requesting HealthKit authorization: \(error)")
            return false
        }
    }
    
    func fetchSleepData(for date: Date) async -> (totalSleep: TimeInterval,
                                                  remSleep: TimeInterval,
                                                  coreSleep: TimeInterval,
                                                  deepSleep: TimeInterval,
                                                  unspecifiedSleep: TimeInterval,
                                                  awakeTime: TimeInterval,
                                                  firstSleep: Date?,
                                                  lastSleep: Date?) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return (0, 0, 0, 0, 0, 0, nil, nil)
        }
        
        let calendar = Calendar.current
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date)!
        let previousDay = calendar.date(byAdding: .day, value: -1, to: date)!
        let previousDayEvening = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: previousDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: previousDayEvening,
                                                    end: noon,
                                                    options: [])
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType,
                                      predicate: predicate,
                                      limit: 0,
                                      sortDescriptors: nil) { _, results, error in
                guard let samples = results as? [HKCategorySample], error == nil else {
                    continuation.resume(returning: (0, 0, 0, 0, 0, 0, nil, nil))
                    return
                }
                
                let validSamples = samples.filter {
                    $0.endDate > previousDayEvening && $0.startDate < noon
                }.sorted { $0.startDate < $1.startDate }
                
                var totalSleep: TimeInterval = 0
                var remSleep: TimeInterval = 0
                var coreSleep: TimeInterval = 0
                var deepSleep: TimeInterval = 0
                var unspecifiedSleep: TimeInterval = 0
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
                        
                    case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                        unspecifiedSleep += duration
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
                
                continuation.resume(returning: (
                    totalSleep,
                    remSleep,
                    coreSleep,
                    deepSleep,
                    unspecifiedSleep,
                    awakeTime,
                    firstSleep,
                    lastSleep
                ))
            }
            
            self.healthStore.execute(query)
        }
    }
}
