import SwiftUI
import SwiftData

struct RestednessInputView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RestednessViewModel
    @State private var restednessScore: Double = 3
    @State private var showingSaveConfirmation = false
    
    private let emojis = ["😫", "😔", "😐", "😊", "😃"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 20) {
                        Text("How rested do you feel?")
                            .font(.headline)
                        
                        // Emoji indicators
                        HStack(spacing: 30) {
                            ForEach(emojis, id: \.self) { emoji in
                                Text(emoji)
                                    .font(.system(size: 30))
                                    .opacity(getEmojiOpacity(for: emoji))
                            }
                        }
                        .padding(.vertical)
                        
                        // Slider
                        Slider(value: $restednessScore, in: 1...5, step: 0.5)
                            .tint(.blue)
                        
                        // Score display
                        Text(String(format: "Score: %.1f", restednessScore))
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
                    viewModel.showingRestednessInput = false
                }
            } message: {
                Text("Your restedness score has been saved.")
            }
        }
    }
    
    private func getEmojiOpacity(for emoji: String) -> Double {
        let index = Double(emojis.firstIndex(of: emoji) ?? 0) + 1
        return 1.0 - min(abs(restednessScore - index), 1.0)
    }
        
    private func saveRestednessScore() {
        viewModel.saveRestednessScore(restednessScore)
        showingSaveConfirmation = true
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SleepData.self, configurations: config)
    let viewModel = RestednessViewModel(modelContext: container.mainContext)
    return RestednessInputView(viewModel: viewModel)
} 
