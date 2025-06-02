import SwiftUI
import SwiftData

struct DailySleepCard<T: ObservableObject>: View {
    let sleepData: SleepData
    let viewModel: T
    let durationFormatter: (TimeInterval) -> String
    @StateObject private var restednessViewModel: RestednessViewModel
    @State private var showingRestednessInput = false
    
    init(sleepData: SleepData, viewModel: T, durationFormatter: @escaping (TimeInterval) -> String, modelContext: ModelContext) {
        self.sleepData = sleepData
        self.viewModel = viewModel
        self.durationFormatter = durationFormatter
        self._restednessViewModel = StateObject(wrappedValue: RestednessViewModel(modelContext: modelContext))
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
            
            if sleepData.restednessScore > 0 {
                HStack {
                    Text("Restedness:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.1f", sleepData.restednessScore))
                        .font(.subheadline)
                    
                    Text(getEmojiForScore(sleepData.restednessScore))
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Button("Edit") {
                        restednessViewModel.currentSleepData = sleepData
                        showingRestednessInput = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            } else {
                Button {
                    restednessViewModel.currentSleepData = sleepData
                    showingRestednessInput = true
                } label: {
                    Text("Rate Your Sleep")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if !sleepData.notes.isEmpty {
                Text(sleepData.notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
        .sheet(isPresented: $showingRestednessInput) {
            RestednessInputView(viewModel: restednessViewModel)
        }
    }
    
    private func getEmojiForScore(_ score: Double) -> String {
        switch score {
        case 1..<2: return "😫"
        case 2..<3: return "😔"
        case 3..<4: return "😐"
        case 4..<4.5: return "😊"
        case 4.5...5: return "😃"
        default: return ""
        }
    }
}

//#Preview{
//    // Create in-memory SwiftData container
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: SleepData.self, configurations: config)
//    
//    // Create sample sleep data
//    let sleepData = SleepData(date: Date())
//    sleepData.totalSleepDuration = 8 * 3600 // 8 hours
//    sleepData.remSleepDuration = 2 * 3600 // 2 hours
//    sleepData.coreSleepDuration = 4 * 3600 // 4 hours
//    sleepData.deepSleepDuration = 2 * 3600 // 2 hours
//    sleepData.awakeDuration = 0.5 * 3600 // 30 minutes
//    sleepData.sleepStart = Calendar.current.date(bySettingHour: 22, minute: 30, second: 0, of: Date())
//    sleepData.sleepEnd = Calendar.current.date(bySettingHour: 6, minute: 30, second: 0, of: Date())
//    
//    // Add some sample restedness data
//    sleepData.restednessScore = 4.5
//    sleepData.notes = "Felt very refreshed after a good night's sleep!"
//    
//    // Insert into context
//    container.mainContext.insert(sleepData)
//    
//    // Simple mock view model
//    class MockViewModel: ObservableObject {
//        func getFormattedDuration(_ duration: TimeInterval) -> String {
//            let hours = Int(duration / 3600)
//            let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
//            "\(hours)h \(minutes)m"
//        }
//    }
//    
//    // Create preview with dark and light variants
//    Group {
//        DailySleepCard(
//            sleepData: sleepData,
//            viewModel: MockViewModel(),
//            durationFormatter: { duration in
//                let hours = Int(duration / 3600)
//                let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
//                return "\(hours)h \(minutes)m"
//            },
//            modelContext: container.mainContext
//        )
//        .padding()
//        .previewDisplayName("Light Mode")
//        
//        DailySleepCard(
//            sleepData: sleepData,
//            viewModel: MockViewModel(),
//            durationFormatter: { duration in
//                let hours = Int(duration / 3600)
//                let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
//                return "\(hours)h \(minutes)m"
//            },
//            modelContext: container.mainContext
//        )
//        .padding()
//        .preferredColorScheme(.dark)
//        .previewDisplayName("Dark Mode")
//    }
//}
