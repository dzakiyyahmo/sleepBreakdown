
import SwiftUI


struct SleepStageInfoSheetContentView: View {
    let stage: SleepStageInfo // Use the enum defined in DailyView or move enum outside
    @Environment(\.dismiss) var dismiss // To add a dismiss button
    
    var body: some View {
        NavigationView { // Wrap in NavigationView for a toolbar and title
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    switch stage {
                    case .awake:
                        Text("What is Awake?")
                            .font(.system(size: FontSizes.h5, weight: .semibold))
                            .foregroundStyle(ColorPalette.awake)
                        Text("It takes time to fall asleep and we wake up periodically throughout the night. This time is represented as Awake in your charts.")
                            .font(.system(size: FontSizes.p, weight: .medium))
                    case .rem:
                        Text("What is REM?")
                            .font(.system(size: FontSizes.h5, weight: .semibold))
                            .foregroundStyle(ColorPalette.rem)
                        Text("Studies show that REM sleep may play a key role in memory and refreshing your brain. It's where most of your dreaming happens. Your eyes will also move side to side. REM sleep first occurs about 90 minutes after falling asleep.")
                            .font(.system(size: FontSizes.p, weight: .medium))
                    case .core:
                        Text("What is Core?")
                            .font(.system(size: FontSizes.h5, weight: .semibold))
                            .foregroundStyle(ColorPalette.core)
                        Text("This stage, where muscle activity lowers and body temperature drops, represents the bulk of your time asleep. While it's sometimes referred to as light sleep, it's just as critical as any other sleep stage.")
                            .font(.system(size: FontSizes.p, weight: .medium))
                    case .deep:
                        Text("What is Deep?")
                            .font(.system(size: FontSizes.h5, weight: .semibold))
                            .foregroundStyle(ColorPalette.deep)
                        Text("Also known as slow wave sleep, this stage allows the body to repair itself and release essential hormones. It happens in longer periods during the first half of the night. It's often difficult to wake up from deep sleep because you're so relaxed.")
                            .font(.system(size: FontSizes.p, weight: .medium))
                    case .unknown:
                        Text("What is Unknown?")
                            .font(.system(size: FontSizes.h5, weight: .semibold))
                            .foregroundStyle(ColorPalette.unspecified)
                        Text("In Apple sleep data, Unspecified indicates periods when the device cannot accurately determine the current sleep stage. This can happen due to unclear sensor data, the device not being worn properly, or other disruptions. During Unspecified times, the Apple Watch is unable to classify whether you are in light sleep, deep sleep, REM, or even awake.")
                            .font(.system(size: FontSizes.p, weight: .medium))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
            }
            .scrollIndicators(.hidden)
            .navigationTitle(navigationTitle(for: stage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { // Or .navigationBarTrailing
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func navigationTitle(for stage: SleepStageInfo) -> String {
            switch stage {
            case .awake: return "About Awake Time"
            case .rem: return "About REM Sleep"
            case .core: return "About Core Sleep"
            case .deep: return "About Deep Sleep"
            case .unknown: return "About Unknown Sleep"
            }
        }
}
