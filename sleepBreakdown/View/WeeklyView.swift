import SwiftUI
import SwiftData
import Charts
import Orb

struct WeeklyView: View {
    @StateObject private var viewModel: WeeklyViewModel
    
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
//                // MARK: -- Orb View based on prediction score
//                if let prediction = viewModel.predictedRestednessForNextWeek {
//                    OrbView(configuration: orbConfiguration(for: prediction))
//                        .frame(width: 150, height: 150) // Adjust size as needed
//                        .padding(.top) // Add padding above the orb
//                } else {
//                    // Default orb or placeholder if prediction is not available
//                    OrbView(configuration: shadowOrb) // Use shadowOrb configuration when no data
//                        .frame(width: 150, height: 150)
//                        .padding(.top)
//                }
//                
//                // MARK: -- Display the prediction card with background image
//                if let prediction = viewModel.predictedRestednessForNextWeek {
//                    let percentage = ((prediction + 1) / 2) * 100 // Convert to percentage
//                    let imageName = backgroundCardImageName(for: percentage)
//                    
//                    ZStack {
//                        // Background Image
//                        Image(imageName)
//                            .resizable()
//                            .frame(width: 326, height: 126)
//                            .cornerRadius(15) // Match the card style in the image
//                        
//                        VStack(alignment: .leading, spacing: 0) { // Main VStack for all text content
//                            
//                            HStack(alignment: .top) { // HStack for title and percentage in the top section
//                                VStack(alignment: .leading) { // VStack specifically for the title
//                                    Text("Prediction Restedness \nfor Next Week") // Title with manual line break
//                                        .font(.headline)
//                                        .foregroundColor(.white)
//                                        .padding(.top, 15)
//                                        .padding(.leading, 15)// Padding above the title
//                                        .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
//                                }
//                                
//                                Spacer() // Push percentage to the right
//                                
//                                Text(String(format: "%.0f%%", percentage)) // Percentage text
//                                    .font(.system(size: 45, weight: .bold)) // Large font for percentage
//                                    .fontWeight(.bold)
//                                    .foregroundColor(.white)
//                                    .padding(.top, 25) // Increased padding above percentage to push it down more
//                                    .padding(.trailing, 20) // Padding on the right
//                            }
//                            
//                            Divider() // Horizontal divider line
//                                .background(Color.white.opacity(0.5)) // Make divider visible
//                                .padding(.horizontal, 20) // Add horizontal padding to divider
//                                .padding(.top, 8) // Increased space above divider
//                                .padding(.bottom, 8) // Increased space below divider
//                            
//                            Text(restednessMessage(for: percentage)) // Message text
//                                .font(.caption)
//                                .foregroundColor(.white)
//                                .multilineTextAlignment(.center)
//                                .frame(maxWidth: .infinity, alignment: .center) // Ensure message is centered
//                                .padding(.horizontal, 20) // Add horizontal padding to message
//                                .padding(.top, 2) // Keep padding above the message (distance from divider)
//                                .padding(.bottom, 15) // Padding below the message
//                                .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
//                            
//                        }
//                        // Removed frame and padding from the outer VStack, padding handled by elements inside
//                        // .padding(.horizontal, 20)
//                        // .frame(width: 326, height: 126, alignment: .leading)
//                    }
//                    // Frame applied to ZStack to control card size
//                    .frame(width: 326, height: 126)
//                    .padding(.top) // Padding above the card
//                } else {
//                    // Display loading or no data message if prediction is not available
//                    Text(viewModel.predictionErrorMessage ?? "Calculating prediction...")
//                        .foregroundColor(.secondary)
//                        .padding(.top)
//                }
                
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
    
    // Function to determine the background card image name based on percentage
    private func backgroundCardImageName(for percentage: Double) -> String {
        if percentage < 68 { // Less than 68%
            return "sunsetcard"
        } else if percentage < 77 { // 68% to less than 77%
            return "firecard"
        } else { // 77% or more
            return "oceancard"
        }
    }
    
    // Function to determine the message based on percentage
    private func restednessMessage(for percentage: Double) -> String {
        if percentage < 68 { // Less than 68% (corresponds to Sunset)
            return "It's a bit low! \nYou are rather low in restedness score."
        } else if percentage < 77 { // 68% to less than 77% (corresponds to Fire)
            return "It's low! \nIf this pattern continues, seek physician."
        } else { // 77% or more (corresponds to Ocean)
            return "Keep this up! \nYou are well-rested this week."
        }
    }
    
    // Function to determine OrbConfiguration based on prediction score (-1 to 1)
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
}

extension TimeInterval {
    var formatted: String {
        let hours = Int(self / 3600)
        let minutes = Int((self.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
}
