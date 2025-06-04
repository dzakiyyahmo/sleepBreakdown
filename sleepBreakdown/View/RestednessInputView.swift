import SwiftUI
import SwiftData

struct RestednessInputView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RestednessViewModel
    @State private var restednessScore: Double = 0.0 // Changed initial value
    @State private var showingSaveConfirmation = false
    
    // Emojis are removed as the scale is changing
    // private let emojis = ["😫", "😔", "😐", "😊", "😃"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 20) {
                        Text("How rested do you feel?")
                            .font(.headline)
                        
                        // Emoji indicators and related HStack are removed
                        
                        // Slider updated for -1 to 1 range
                        Slider(value: $restednessScore, in: -1...1, step: 0.1) // Changed range and step
                            .tint(.blue)
                        
                        // Score display
                        Text(String(format: "Score: %.1f", restednessScore)) // Format can remain or change to %.2f for more precision
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .navigationTitle("Rate Your Sleep")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // dismiss() // Consider using dismiss directly if viewModel.showingRestednessInput is only for presentation
                        viewModel.showingRestednessInput = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRestednessScore()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert("Score Saved", isPresented: $showingSaveConfirmation) {
                Button("OK") {
                    // dismiss() // Consider using dismiss directly
                    viewModel.showingRestednessInput = false
                }
            } message: {
                Text("Your restedness score has been saved.")
            }
            // If this view is presented as a sheet, .onAppear might be useful
            // to load the existing score if currentSleepData is available and has a score.
            .onAppear {
                if let currentScore = viewModel.currentSleepData?.restednessScore {
                    // If the score in SleepData is still in the old 1-5 range, you'd need to convert it
                    // or ensure it's already -1 to 1. Assuming it will be -1 to 1 moving forward.
                    // If SleepData.restednessScore is 0 by default and 0 is a valid selectable value,
                    // this will set the slider to 0.
                    // To distinguish "not set" from "set to 0", you might need SleepData.restednessScore to be Optional.
                    if currentScore >= -1 && currentScore <= 1 { // Basic check if score is in new range
                        restednessScore = currentScore
                    } else if viewModel.currentSleepData?.restednessScore != 0 { // If it's the default 0, don't override slider's 0
                        // Handle conversion from old scale if necessary, or reset
                        // For now, we assume new scores will be in the -1 to 1 range.
                        // If the stored score '0' means "not yet set" from SleepData's init,
                        // and the slider also defaults to 0.0, then it's consistent.
                    }
                }
            }
        }
    }
    
    // getEmojiOpacity function is removed
    
    private func saveRestednessScore() {
        viewModel.saveRestednessScore(restednessScore)
        showingSaveConfirmation = true
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SleepData.self, configurations: config)
    let viewModel = RestednessViewModel(modelContext: container.mainContext)
    
    // For preview, you can simulate having a SleepData object
    // let sampleSleepData = SleepData(date: Date())
    // sampleSleepData.restednessScore = 0.5 // example score in the new range
    // container.mainContext.insert(sampleSleepData)
    // viewModel.currentSleepData = sampleSleepData
    
    return RestednessInputView(viewModel: viewModel)
}
