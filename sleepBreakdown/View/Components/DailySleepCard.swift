import SwiftUI

struct DailySleepCard<T: ObservableObject>: View {
    let sleepData: SleepData
    let viewModel: T
    let durationFormatter: (TimeInterval) -> String
    
    init(sleepData: SleepData, viewModel: T, durationFormatter: @escaping (TimeInterval) -> String) {
        self.sleepData = sleepData
        self.viewModel = viewModel
        self.durationFormatter = durationFormatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(sleepData.date, style: .date)
                    .font(.headline)
                
                Spacer()
                
                if let start = sleepData.sleepStart,
                   let end = sleepData.sleepEnd {
                    Text("\(start, style: .time) - \(end, style: .time)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                SleepStageBar(
                    rem: sleepData.remSleepDuration,
                    core: sleepData.coreSleepDuration,
                    deep: sleepData.deepSleepDuration,
                    awake: sleepData.awakeDuration
                )
                .frame(height: 8)
                
                Text(durationFormatter(sleepData.totalSleepDuration))
                    .font(.system(.body, design: .monospaced))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
}


#Preview("DailySleepCard") {
    // Sample data for DailySleepCard
    let sleepData = SleepData(date: Date())
    sleepData.totalSleepDuration = 8 * 3600 // 8 hours
    sleepData.remSleepDuration = 2 * 3600 // 2 hours
    sleepData.coreSleepDuration = 4 * 3600 // 4 hours
    sleepData.deepSleepDuration = 2 * 3600 // 2 hours
    sleepData.sleepStart = Calendar.current.date(bySettingHour: 22, minute: 30, second: 0, of: Date())
    sleepData.sleepEnd = Calendar.current.date(bySettingHour: 6, minute: 30, second: 0, of: Date())
    
    // Mock ViewModel
    class MockViewModel: ObservableObject {
        func getFormattedDuration(for duration: TimeInterval) -> String {
            let hours = Int(duration / 3600)
            let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
            return "\(hours)h \(minutes)m"
        }
    }
    
    return DailySleepCard(
        sleepData: sleepData,
        viewModel: MockViewModel(),
        durationFormatter: { duration in
            let hours = Int(duration / 3600)
            let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
            return "\(hours)h \(minutes)m"
        }
    )
    .padding()
}
