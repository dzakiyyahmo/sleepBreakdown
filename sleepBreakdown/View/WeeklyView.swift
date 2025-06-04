import SwiftUI
import SwiftData
import Charts
import Orb



struct WeeklyView: View {
    @State private var isShowingSheet = false
    @StateObject private var viewModel: WeeklyViewModel
    @State private var selectedSleepStageForSheet: SleepStageInfo? = nil
    
    // Define shadowOrb configuration
    private let shadowOrb = OrbConfiguration(
        backgroundColors: [.black, .gray],
        glowColor: .gray,
        coreGlowIntensity: 0.7,
        showParticles: false
    )
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: WeeklyViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                CustomOrbComponent(preset: viewModel.orbPreset, size: 150)
                
                Text("Last week you asleep for")
                    .font(.system(size: FontSizes.h6, weight: .medium))
                    .padding(.bottom, 2)
                
                Text(viewModel.getFormattedDuration(for: viewModel.averageSleepDuration))
                    .font(.system(size: FontSizes.h2, weight: .bold))
                    .padding(.bottom, 12)
                VStack{
                    Text("The orb shows how your sleep was. ")
                    Text("It changes in response to your sleep structures.")
                }
                .font(.system(size: FontSizes.sm))
                .foregroundStyle(Color.gray.opacity(0.9))
                
                HStack {
                    Image(systemName: "chevron.left").onTapGesture {
                        viewModel.moveToPreviousWeek()
                    }
                    //Text("Monday, 19 May 2025")
                    Text(Calendar.current.weekDateRange(for: viewModel.currentWeekStart))
                        .font(.headline)
                        .font(.system (size: FontSizes.p, weight: .medium))
                        .padding([.leading, .trailing], 80)
                    Image(systemName: "chevron.right").onTapGesture {
                        viewModel.moveToNextWeek()
                    }
                }.padding([.top, .bottom], 32)
                
                
                //                // Week Navigation
                //                weekNavigationView
                
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
        .sheet(item: $selectedSleepStageForSheet) { stageInfo in
            SleepStageInfoSheetContentView(stage: stageInfo) // Re-use the sheet content view
                .presentationDetents([.medium]) // Make sheet non-fullscreen
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
            Grid (horizontalSpacing: 24, verticalSpacing: 24) {
                GridRow {
                    Bento(title: "Avg Awake", duration: viewModel.getFormattedDuration(for: viewModel.averageAwakeTime), color: ColorPalette.awake)
                        .onTapGesture {
                            selectedSleepStageForSheet = .awake
                        }
                    
                    Bento(title: "Avg REM", duration: viewModel.getFormattedDuration(for: viewModel.averageRemSleep), color: ColorPalette.rem)
                        .onTapGesture {
                            selectedSleepStageForSheet = .rem
                        }
                }
                GridRow {
                    Bento(title: "Avg Core", duration: viewModel.getFormattedDuration(for: viewModel.averageCoreSleep), color: ColorPalette.core)
                        .onTapGesture {
                            selectedSleepStageForSheet = .core
                        }
                    Bento(title: "Avg Deep", duration: viewModel.getFormattedDuration(for: viewModel.averageDeepSleep), color: ColorPalette.deep)
                        .onTapGesture {
                            selectedSleepStageForSheet = .deep
                        }
                }
                GridRow {
                    Bento(title: "Avg Unknown", duration:viewModel.getFormattedDuration(for: viewModel.averageUnspecifiedSleep), color: ColorPalette.unspecified)
                        .onTapGesture {
                            selectedSleepStageForSheet = .unknown
                        }
                    Bento(title: "Avg Restful",
                          duration: viewModel.getFormattedRestednessPercentage(for: viewModel.averageRestednessScore), // Use the average score
                          color: ColorPalette.rest)
                }
                
            }.scrollIndicators(.hidden)
            
        }
        
    }

    
    private func orbConfiguration(for prediction: Double) -> OrbConfiguration {
        // Convert prediction (-1 to 1) to percentage (0 to 100)
        let percentage = ((prediction + 1) / 2) * 100
        
        // Logic based on percentage
        if percentage < 68 { // Less than 33%
            // Sunset configuration
            return OrbConfiguration(
                backgroundColors: [.orange, .red, .pink],
                glowColor: .orange,
                coreGlowIntensity: 0.8
            )
        } else if percentage < 77 { // 33% to less than 66%
            // Fire configuration
            return OrbConfiguration(
                backgroundColors: [.red, .orange, .yellow],
                glowColor: .orange,
                coreGlowIntensity: 1.3,
                speed: 80
            )
        } else { // 66% or more
            // Ocean configuration
            return OrbConfiguration(
                backgroundColors: [.blue, .cyan, .teal],
                glowColor: .cyan,
                speed: 75
            )
        }
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
    
}

extension TimeInterval {
    var formatted: String {
        let hours = Int(self / 3600)
        let minutes = Int((self.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
}
