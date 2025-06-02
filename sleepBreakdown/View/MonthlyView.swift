import SwiftUI
import SwiftData
import Charts

struct MonthlyView: View {
    @StateObject private var viewModel: MonthlyViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: MonthlyViewModel(modelContext: modelContext))
    }
//MARK: --Main View
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Month Navigation
                monthNavigationView
                
                // Monthly Statistics
                monthlyStatsView
                
                // Sleep Chart
                sleepChartView
                
                // Daily Breakdown
                dailyBreakdownView
            }
            .padding()
        }
        .task {
            await viewModel.fetchMonthlyData()
        }
    }
//MARK: --NavigationView
    private var monthNavigationView: some View {
        HStack {
            Button(action: {
                viewModel.moveToPreviousMonth()
            }) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(Calendar.current.monthDateRange(for: viewModel.currentMonthStart))
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                viewModel.moveToNextMonth()
            }) {
                Image(systemName: "chevron.right")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
        }
    }
//MARK: -- Stats View
    private var monthlyStatsView: some View {
        VStack(spacing: 15) {
            Text("Monthly Summary")
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
//MARK: --Chart View
    private var sleepChartView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sleep Duration")
                .font(.headline)
            
            Chart(viewModel.monthlyData) { data in
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
                        AxisValueLabel(format: .dateTime.day())
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
            
            ForEach(viewModel.monthlyData) { data in
                DailySleepCard(
                    sleepData: data,
                    viewModel: viewModel,
                    durationFormatter: viewModel.getFormattedDuration
                )
            }
        }
    }
}

