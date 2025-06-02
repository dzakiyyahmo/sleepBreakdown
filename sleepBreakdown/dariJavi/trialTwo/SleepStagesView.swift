import SwiftUI

struct SleepStagesView: View {
    @StateObject private var viewModel = SleepStagesViewModel()
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .onChange(of: selectedDate) { oldDate, newDate in
                        viewModel.requestAndFetch(for: newDate)
                    }
                }
                
                Section("Sleep Time") {
                    if let start = viewModel.sleepStart,
                       let end = viewModel.sleepEnd {
                        HStack {
                            Text("From")
                            Spacer()
                            Text(formatTime(start))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("To")
                            Spacer()
                            Text(formatTime(end))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("No sleep data available")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Sleep Analysis") {
                    SleepDurationRow(title: "Total Sleep", duration: viewModel.totalSleepDuration)
                    
                    SleepDurationRow(title: "REM Sleep", duration: viewModel.remSleepDuration)
                        .foregroundColor(.purple)
                    
                    SleepDurationRow(title: "Core Sleep", duration: viewModel.coreSleepDuration)
                        .foregroundColor(.blue)
                    
                    SleepDurationRow(title: "Deep Sleep", duration: viewModel.deepSleepDuration)
                        .foregroundColor(.indigo)
                    
                    SleepDurationRow(title: "Time Awake", duration: viewModel.awakeDuration)
                        .foregroundColor(.orange)
                }
            }
            .navigationTitle("Sleep Analysis")
        }
        .onAppear {
            viewModel.requestAndFetch(for: selectedDate)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SleepDurationRow: View {
    let title: String
    let duration: TimeInterval
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(formatDuration(duration))
                .foregroundColor(.secondary)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    SleepStagesView()
} 
