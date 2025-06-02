import Foundation
import HealthKit

class SleepStartEndViewModel: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published var sleepStart: Date?
    @Published var sleepEnd: Date?

    func requestAndFetch(for date: Date) {
        guard HKHealthStore.isHealthDataAvailable(),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        healthStore.requestAuthorization(toShare: [], read: [sleepType]) { [weak self] success, _ in
            if success {
                self?.fetchSleep(for: date)
            }
        }
    }

    private func fetchSleep(for date: Date) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfNight = calendar.date(byAdding: .hour, value: 18, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfNight, options: [])

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 0, sortDescriptors: nil) { _, results, error in
            guard let samples = results as? [HKCategorySample], error == nil else { return }

            let asleepValues = Set([
                HKCategoryValueSleepAnalysis.asleepREM.rawValue,
                HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                HKCategoryValueSleepAnalysis.asleepDeep.rawValue
            ])

            let asleepSegments = samples.filter {
                asleepValues.contains($0.value) &&
                $0.endDate > startOfDay &&
                $0.startDate < endOfNight
            }

            // Filter to segments at least 5 minutes long
            let meaningfulAsleep = asleepSegments.filter {
                $0.endDate.timeIntervalSince($0.startDate) >= 300
            }.sorted { $0.startDate < $1.startDate }

            guard let first = meaningfulAsleep.first else { return }

            // Find the last segment where after it we don't sleep again
            var last = meaningfulAsleep.last

            if let lastIndex = meaningfulAsleep.indices.last {
                for i in lastIndex..<meaningfulAsleep.count {
                    let current = meaningfulAsleep[i]
                    let nextStart = i + 1 < meaningfulAsleep.count ? meaningfulAsleep[i + 1].startDate : nil
                    let gap = nextStart.map { $0.timeIntervalSince(current.endDate) } ?? Double.infinity
                    if gap >= 600 { // 10 minutes gap
                        last = current
                        break
                    }
                }
            }

            DispatchQueue.main.async {
                self.sleepStart = first.startDate
                self.sleepEnd = last?.endDate
            }
        }

        healthStore.execute(query)
    }
}
