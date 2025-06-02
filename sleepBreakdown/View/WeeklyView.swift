import SwiftUI
import SwiftData
import Charts

struct WeeklyView: View {
    @StateObject private var viewModel: WeeklyViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: WeeklyViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                //MARK: --Display the prediction
                VStack(spacing: 5) {
                    Text("Predicted Restedness for Next Week:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Display the prediction if available
                    if let prediction = viewModel.predictedRestednessForNextWeek {
                        Text(String(format: "%.1f / 1.0", prediction)) //
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.purple) // Make it stand out
                    }
                    // Handle cases where prediction is not available
                    else if viewModel.predictedRestednessForNextWeek == nil && viewModel.predictionErrorMessage == nil {
                        // This case means no prediction, AND no general error yet.
                        // Implies data might be missing from previous week or still loading.
                        Text("No data from previous week for prediction.")
                            .foregroundColor(.secondary)
                    }
                    // Display general error message if there is one
                    else if let error = viewModel.predictionErrorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    // Default loading state
                    else {
                        Text("Calculating prediction...")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom) // Add some space below the prediction
                
                // Week Navigation
                weekNavigationView
                
                // Weekly Statistics
                weeklyStatsView
                
                // Sleep Chart
                sleepChartView
                
                // Daily Breakdown
                dailyBreakdownView
            }
            .padding()
        }
        .task {
            await viewModel.fetchWeeklyData()
        }
    }
    
    private var weekNavigationView: some View {
        HStack {
            Button(action: {
                viewModel.moveToPreviousWeek()
            }) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(Calendar.current.weekDateRange(for: viewModel.currentWeekStart))
                .font(.headline)
            
            Spacer()
            
            Button(action: {
                viewModel.moveToNextWeek()
            }) {
                Image(systemName: "chevron.right")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var weeklyStatsView: some View {
        VStack(spacing: 15) {
            Text("Weekly Summary")
                .font(.title2)
                .fontWeight(.bold)
            
            if viewModel.daysWithSleepCount > 0 {
                Text("\(viewModel.daysWithSleepCount) days with sleep data")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Total and Average Sleep
            HStack(spacing: 20) {
                StatCard(
                    title: "Average Sleep",
                    value: viewModel.getFormattedDuration(for: viewModel.averageSleepDuration),
                    icon: "bed.double.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Total Sleep",
                    value: viewModel.getFormattedDuration(for: viewModel.totalSleepTime),
                    icon: "clock.fill",
                    color: .green
                )
            }
            
            // Sleep Stages Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatCard(
                    title: "Avg REM Sleep",
                    value: viewModel.getFormattedDuration(for: viewModel.averageRemSleep),
                    icon: "moon.stars.fill",
                    color: .purple
                )
                
                StatCard(
                    title: "Avg Core Sleep",
                    value: viewModel.getFormattedDuration(for: viewModel.averageCoreSleep),
                    icon: "moon.fill",
                    color: .indigo
                )
                
                StatCard(
                    title: "Avg Deep Sleep",
                    value: viewModel.getFormattedDuration(for: viewModel.averageDeepSleep),
                    icon: "moon.zzz.fill",
                    color: .teal
                )
                
                StatCard(
                    title: "Avg Awake Time",
                    value: viewModel.getFormattedDuration(for: viewModel.averageAwakeTime),
                    icon: "eye.fill",
                    color: .orange
                )
            }
            
            // Deep Sleep Percentage
            //            StatCard(
            //                title: "Deep Sleep",
            //                value: viewModel.getFormattedPercentage(for: viewModel.averageDeepSleepPercentage),
            //                icon: "percent",
            //                color: .purple
            //            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private var sleepChartView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sleep Duration")
                .font(.headline)
            
            Chart(viewModel.weeklyData) { data in
                BarMark(
                    x: .value("Day", data.date, unit: .day),
                    y: .value("Hours", data.totalSleepDuration / 3600)
                )
                .foregroundStyle(Color.blue.gradient)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if value.as(Date.self) != nil {
                        AxisValueLabel(format: .dateTime.weekday(.short))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private var dailyBreakdownView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Daily Breakdown")
                .font(.headline)
            
            ForEach(viewModel.weeklyData) { data in
                DailySleepCard(
                    sleepData: data,
                    viewModel: viewModel,
                    durationFormatter: viewModel.getFormattedDuration,
                    modelContext: viewModel.modelContext
                )
            }
        }
    }
}

extension TimeInterval {
    var formatted: String {
        let hours = Int(self / 3600)
        let minutes = Int((self.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
}
