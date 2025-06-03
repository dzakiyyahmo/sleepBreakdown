import SwiftUI
import SwiftData

struct DailyView: View {
    @StateObject private var viewModel: DailyViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: DailyViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Date Navigation
            HStack {
                // Previous Day Button
                Button(action: {
                    viewModel.moveToPreviousDay()
                }) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Date Display in center
                dateHeader
                
                Spacer()
                
                // Next Day Button
                Button(action: {
                    viewModel.moveToNextDay()
                }) {
                    Image(systemName: "chevron.right")
                        .imageScale(.large)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Sleep Stages Container
            sleepStagesContainer
                .frame(maxWidth: .infinity)
                .animation(.easeOut, value: viewModel.currentDate)
            
            Spacer()
            ZStack{
                PredictCard() // Your custom background card
                VStack {
                    Text("Predicted Restedness for Tomorrow") // More descriptive title
                        .font(.headline) // Adjusted font
                        .foregroundStyle(.white)
                    
                    // Display the predictedRestednessForTomorrow from the ViewModel
                    if let predictedRestedness = viewModel.predictedRestednessForTomorrow {
                        Text("\(predictedRestedness, specifier: "%.0f")%") // Format as a percentage with no decimal places
                            .font(.largeTitle) // Make it prominent
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    } else if let errorMessage = viewModel.dailyPredictionErrorMessage {
                        Text("Error: \(errorMessage)") // Show error if prediction failed
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal) // Add some padding for better readability
                    } else {
                        // Show a placeholder or loading state if no prediction yet
                        Text("— %") // Or "Loading..."
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            
        }
        .padding()
        .onAppear {
            viewModel.fetchSleepData()
        }
    }
    
    private var dateHeader: some View {
        VStack {
            Text(viewModel.currentDate, style: .date)
                .font(.title2)
                .fontWeight(.bold)
            
            if let start = viewModel.sleepData?.sleepStart,
               let end = viewModel.sleepData?.sleepEnd {
                HStack {
                    Text(start, style: .time)
                    Text("→")
                    Text(end, style: .time)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
        }
    }
    
    private var sleepStagesContainer: some View {
        VStack(spacing: 15) {
            Text("Sleep Stages")
                .font(.headline)
            
            if let sleepData = viewModel.sleepData {
                SleepStageRow(title: "Total Sleep",
                              duration: sleepData.totalSleepDuration,
                              color: .blue,
                              viewModel: viewModel)
                
                SleepStageRow(title: "REM Sleep",
                              duration: sleepData.remSleepDuration,
                              color: .purple,
                              viewModel: viewModel)
                
                SleepStageRow(title: "Core Sleep",
                              duration: sleepData.coreSleepDuration,
                              color: .indigo,
                              viewModel: viewModel)
                
                SleepStageRow(title: "Deep Sleep",
                              duration: sleepData.deepSleepDuration,
                              color: .teal,
                              viewModel: viewModel)
                
                SleepStageRow(title: "Time Awake",
                              duration: sleepData.awakeDuration,
                              color: .orange,
                              viewModel: viewModel)
            } else {
                Text("No sleep data available")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
}



struct SleepStageRow: View {
    let title: String
    let duration: TimeInterval
    let color: Color
    let viewModel: DailyViewModel
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(title)
            
            Spacer()
            
            Text(viewModel.getFormattedDuration(for: duration))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SleepData.self, configurations: config)
        return DailyView(modelContext: container.mainContext)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
