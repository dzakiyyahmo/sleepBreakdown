




import SwiftUI
import SwiftData
import Charts
import Orb

struct MonthlyView: View {
    @State private var isShowingSheet = false
    @StateObject private var viewModel: MonthlyViewModel
    
    private let shadowOrb = OrbConfiguration(
        backgroundColors: [.black, .gray],
        glowColor: .gray,
        coreGlowIntensity: 0.7,
        showParticles: false
    )
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: MonthlyViewModel(modelContext: modelContext))
    }
    //MARK: --Main View
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CustomOrbComponent(preset: viewModel.orbPreset, size: 150)
                
                Text("Last month you asleep for")
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
                        viewModel.moveToPreviousMonth()
                    }
                    //Text("Monday, 19 May 2025")
                    Text(Calendar.current.monthDateRange(for: viewModel.currentMonthStart))
                        .font(.headline)
                        .font(.system(size: FontSizes.p, weight: .medium))
                        .padding([.leading, .trailing], 80)
                    Image(systemName: "chevron.right").onTapGesture {
                        viewModel.moveToNextMonth()
                    }
                }.padding([.top, .bottom], 32)
                //                // Month Navigation
                //                monthNavigationView
                
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
            
            Grid (horizontalSpacing: 24, verticalSpacing: 24) {
                GridRow {
                    Bento(title: "Avg Awake", duration: viewModel.getFormattedDuration(for: viewModel.averageAwakeTime), color: ColorPalette.awake)
                    
                    Bento(title: "Avg REM", duration: viewModel.getFormattedDuration(for: viewModel.averageRemSleep), color: ColorPalette.rem)
                }
                GridRow {
                    Bento(title: "Avg Core", duration: viewModel.getFormattedDuration(for: viewModel.averageCoreSleep), color: ColorPalette.core)
                    Bento(title: "Avg Deep", duration: viewModel.getFormattedDuration(for: viewModel.averageDeepSleep), color: ColorPalette.deep)
                }
                GridRow {
                    Bento(title: "Avg Unknown", duration:viewModel.getFormattedDuration(for: viewModel.averageUnspecifiedSleep), color: ColorPalette.unspecified)
                    Bento(title: "Avg Restful",
                          duration: viewModel.getFormattedRestednessPercentage(for: viewModel.averageRestednessScore),
                          color: ColorPalette.rest)
                }
                
            }.scrollIndicators(.hidden)
                .sheet(isPresented: $isShowingSheet) {
                    ScrollView {
                        VStack (alignment: .leading, spacing: 18){
                            Text("What is Awake?")
                                .font(.system(size: FontSizes.h5, weight: .semibold))
                                .foregroundStyle(ColorPalette.awake)
                            Text("It takes time to fall asleep and we wake up periodically throughout the night. This time is represented as Awake in your charts.")
                                .font(.system(size: FontSizes.p, weight: .medium))
                            
                            Text("What is REM?")
                                .font(.system(size: FontSizes.h5, weight: .semibold))
                                .foregroundStyle(ColorPalette.rem)
                            Text("Studies show that REM sleep may play a key role in memory and refreshing your brain. It's where most of your dreaming happens. Your eyes will also move side to side. REM sleep first occurs about 90 minutes after falling asleep.")
                                .font(.system(size: FontSizes.p, weight: .medium))
                            
                            Text("What is Core?")
                                .font(.system(size: FontSizes.h5, weight: .semibold))
                                .foregroundStyle(ColorPalette.core)
                            Text("This stage, where muscle activity lowers and body temperature drops, represents the bulk of your time asleep. While it's sometimes referred to as light sleep, it's just as critical as any other sleep stage.")
                                .font(.system(size: FontSizes.p, weight: .medium))
                            
                            Text("What is Deep?")
                                .font(.system(size: FontSizes.h5, weight: .semibold))
                                .foregroundStyle(ColorPalette.deep)
                            Text("Also known as slow wave sleep, this stage allows the body to repair itself and release essential hormones. It happens in longer periods during the first half of the night. It's often difficult to wake up from deep sleep because you're so relaxed.")
                                .font(.system(size: FontSizes.p, weight: .medium))
                            
                            Text("What is Unknown?")
                                .font(.system(size: FontSizes.h5, weight: .semibold))
                                .foregroundStyle(ColorPalette.unspecified)
                            Text("In Apple sleep data, Unspecified indicates periods when the device cannot accurately determine the current sleep stage. This can happen due to unclear sensor data, the device not being worn properly, or other disruptions. During Unspecified times, the Apple Watch is unable to classify whether you are in light sleep, deep sleep, REM, or even awake.")
                            
                            Text("What is Restful?")
                                .font(.system(size: FontSizes.h5, weight: .semibold))
                                .foregroundStyle(ColorPalette.rest)
                            Text("It is your self-reported level of restfulness during the night. A score of 100% indicates you felt very rested, while a score of 0% indicates you felt very tired.")
                                .font(.system(size: FontSizes.p, weight: .medium))
                        }
                    }.scrollIndicators(.hidden)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 24)
                    
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
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
                    durationFormatter: viewModel.getFormattedDuration,
                    modelContext: viewModel.modelContext
                )
            }
        }
    }
}

