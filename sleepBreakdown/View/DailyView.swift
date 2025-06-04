//
//  Home.swift
//  wally
//
//  Created by Rizal Khanafi on 02/06/25.
//

import SwiftUI
import SwiftData

enum SleepStageInfo: String, Identifiable {
    case awake, rem, core, deep, unknown
    var id: String { self.rawValue }
}


struct DailyView: View {
    @State private var selectedSleepStageForSheet: SleepStageInfo? = nil
    @State private var isShowingSheet = false
    @StateObject private var viewModel: DailyViewModel
    @State private var showingRestednessInputSheet = false
    
    private let eightHoursInSeconds: TimeInterval = 8 * 60 * 60 // 28800.0
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: DailyViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        ScrollView  {
            VStack {
                CustomOrbComponent(preset: viewModel.orbPreset, size: 150)
                    .padding(30)
                
                Text("Last night you asleep for")
                    .font(.system(size: FontSizes.h6, weight: .medium))
                    .padding(.bottom, 2)
                
                
                if let sleepData = viewModel.sleepData {
                    Text(viewModel.getFormattedDuration(for: sleepData.totalSleepDuration))
                        .font(.system(size: FontSizes.h2, weight: .bold))
                        .padding(.bottom, 12)
                    
                    
                } else {
                    Text("0h 0m")
                        .font(.system(size: FontSizes.h2, weight: .bold))
                        .padding(.bottom, 12)
                }
                
                VStack{
                    Text("The orb shows how your sleep was. ")
                    Text("It changes in response to your sleep structures.")
                }
                .font(.system(size: FontSizes.sm))
                .foregroundStyle(Color.gray.opacity(0.9))
                
                HStack {
                    Image(systemName: "chevron.left").onTapGesture {
                        viewModel.moveToPreviousDay()
                    }
                    //Text("Monday, 19 May 2025")
                    dateHeader
                        .font(.system(size: FontSizes.p, weight: .medium))
                        .padding([.leading, .trailing], 80)
                    Image(systemName: "chevron.right").onTapGesture {
                        viewModel.moveToNextDay()
                    }
                }.padding([.top, .bottom], 32)
                
                if let sleepData = viewModel.sleepData {
                    Grid (horizontalSpacing: 24, verticalSpacing: 24) {
                        GridRow {
                            Bento(title: "Awake", duration: viewModel.getFormattedDuration(for: sleepData.awakeDuration), color: ColorPalette.awake)
                                .onTapGesture { selectedSleepStageForSheet = .awake }
                            
                            Bento(title: "REM", duration: viewModel.getFormattedDuration(for: sleepData.remSleepDuration), color: ColorPalette.rem)
                                .onTapGesture {
                                    selectedSleepStageForSheet = .rem
                                }
                        }
                        GridRow {
                            Bento(title: "Core", duration: viewModel.getFormattedDuration(for: sleepData.coreSleepDuration), color: ColorPalette.core)
                                .onTapGesture {
                                    selectedSleepStageForSheet = .core
                                }
                            Bento(title: "Deep", duration: viewModel.getFormattedDuration(for: sleepData.deepSleepDuration), color: ColorPalette.deep)
                                .onTapGesture {
                                    selectedSleepStageForSheet = .deep
                                }
                        }
                        GridRow {
                            Bento(title: "Unknown", duration:viewModel.getFormattedDuration(for: sleepData.unspecifiedSleepDuration), color: ColorPalette.unspecified)
                                .onTapGesture {
                                    selectedSleepStageForSheet = .unknown
                                }
                            Bento(title: "Restful",
                                  duration: viewModel.getFormattedRestedness(score: sleepData.restednessScore), // Use the score
                                  color: ColorPalette.rest)
                        }
                    }.padding(.bottom, 18)
//                        .onTapGesture {isShowingSheet.toggle()}
                } else {
                    Text("You have no sleep data recorded on this day.")
                        .foregroundColor(.secondary)
                }
                
                
                if Calendar.current.isDateInToday(viewModel.currentDate) { // Only show for today's view
                    if let sleepData = viewModel.sleepData,
                       sleepData.totalSleepDuration > 0 && sleepData.totalSleepDuration < eightHoursInSeconds {
                        Card(
                            type: "reminder",
                            title: "You were asleep for less than 8 hours.",
                            desc: "In general, adults need 8 hours of sleep every day, and it is a good idea to put in extra effort to achieving that 8-hour sleep goal. Sleep is crucial for your recovery and daily functions."
                        )
                        .padding(.bottom, 10) // Add some spacing if both cards appear
                    }
                }
                
                predictionCard
                
            }
            .padding(.bottom, 40)
        }.scrollIndicators(.hidden)
            .sheet(item: $selectedSleepStageForSheet) { stageInfo in
                // 5. Provide Specific Sheet Content
                SleepStageInfoSheetContentView(stage: stageInfo)
                    .presentationDetents([.height(300)])
            }
        
    }
    
    private var dateHeader: some View {
        VStack {
            Text(viewModel.currentDate, style: .date)
            
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
    
    private var predictionCard: some View {
        Group {
            if let predictedRestedness = viewModel.predictedRestednessForTomorrow {
                Card(
                    type: "prediction",
                    title: "Restfulness prediction, \(String(format: "%.0f", predictedRestedness))%.", // Corrected
                    desc: "Based on your sleep patterns last night, your restfulness prediction is \(String(format: "%.0f", predictedRestedness))%. This means that you are likely to have a restful night tonight." // Corrected
                )
            } else if let errorMessage = viewModel.dailyPredictionErrorMessage {
                Card(
                    type: "prediction",
                    title: "Prediction Unavailable",
                    desc: "Error: \(errorMessage)"
                )
            } else {
                Card(
                    type: "prediction",
                    title: "Restfulness prediction: —%",
                    desc: "No prediction available for today's sleep data."
                )
            }
        }
    }
}


struct Bento: View {
    
    
    var title: String
    var duration: String
    var color: Color
    
    var body: some View {
        ZStack (alignment: .leading) {
            VStack {
                Rectangle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 50)
                    .blur(radius: 30)
                Spacer()
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                HStack (alignment: .top) {
                    Text(title)
                        .font(.system(size: FontSizes.h5, weight: .semibold))
                        .foregroundStyle(color)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: FontSizes.xsm, weight: .bold))
                        .foregroundStyle(Color.gray.opacity(0.5))
                }
                Spacer()
                HStack{
                    Spacer()
                    Text(duration)
                        .font(.system(size: FontSizes.h3, weight: .semibold))
                }
            }.padding(10)
        }.frame(width: 160, height: 120)
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

