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
