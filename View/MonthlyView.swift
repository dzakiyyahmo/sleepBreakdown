ForEach(viewModel.monthlyData) { data in
    DailySleepCard(
        sleepData: data,
        viewModel: viewModel,
        durationFormatter: viewModel.getFormattedDuration,
        modelContext: viewModel.modelContext
    )
} 