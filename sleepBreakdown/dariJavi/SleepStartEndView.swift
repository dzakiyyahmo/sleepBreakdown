import SwiftUI

struct SleepStartEndView: View {
    @StateObject private var viewModel = SleepStartEndViewModel()
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 20) {
            DatePicker("Select Night", selection: $selectedDate, displayedComponents: .date)

            Button("Get Sleep Times") {
                viewModel.requestAndFetch(for: selectedDate)
            }
            .buttonStyle(.borderedProminent)

            if let start = viewModel.sleepStart, let end = viewModel.sleepEnd {
                VStack(spacing: 10) {
                    Text("🛌 Sleep Start: \(format(start))")
                    Text("🔔 Sleep End: \(format(end))")
                }
                .padding(.top)
            } else {
                Text("No sleep data yet.")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }

    private func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

