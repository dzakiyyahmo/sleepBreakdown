//
//  RestednessPredictionService.swift
//  sleepBreakdown
//
//  Created by Dzakiyyah Azahra on 02/06/25.
//

import Foundation
import CoreML

enum RestednessPredictionError: Error, LocalizedError {
    case modelLoadingFailed
    case predictionFailed(Error)
    case invalidInputData(String)
    
    var errorDescription: String? {
        switch self {
        case .modelLoadingFailed:
            return "Failed to load the sleep restedness prediction model."
        case .predictionFailed(let error):
            return "Failed to make a prediction: \(error.localizedDescription)"
        case .invalidInputData(let message):
            return "Invalid input data for prediction: \(message)"
        }
    }
}

class RestednessPredictionService{
    private let model: sleepWellRestedness
    
    init() throws {
        // Attempt to load the Core ML model
        do {
            self.model = try sleepWellRestedness(configuration: MLModelConfiguration())
        } catch {
            throw RestednessPredictionError.modelLoadingFailed
        }
    }
    func predictRestedness(
        awake: TimeInterval,
        core: TimeInterval,
        deep: TimeInterval,
        rem: TimeInterval,
        unspecified: TimeInterval,
        totalSleepDuration: TimeInterval // This is the total sleep from sleepStart to sleepEnd
    ) throws -> Double {
        let awakeMinutes = awake / 60.0
        let coreMinutes = core / 60.0
        let deepMinutes = deep / 60.0
        let remMinutes = rem / 60.0
        let unspecifiedMinutes = unspecified / 60.0
        let totalSleepMinutes = totalSleepDuration / 60.0
        // Core ML models typically expect Int64 inputs. Convert TimeInterval (Double) to Int64 (seconds).
        // Ensure values are non-negative.
        let awakeInt = Int64(max(0, awakeMinutes))
        let coreInt = Int64(max(0, coreMinutes))
        let deepInt = Int64(max(0, deepMinutes))
        let remInt = Int64(max(0, remMinutes))
        let unspecifiedInt = Int64(max(0, unspecifiedMinutes))
        let sleepDurationInt = Int64(max(0, totalSleepMinutes))
        
        
        // Ensure all inputs are valid. Core ML models might crash with negative inputs.
        guard awakeInt >= 0, coreInt >= 0, deepInt >= 0, remInt >= 0,
              unspecifiedInt >= 0, sleepDurationInt >= 0 else {
            throw RestednessPredictionError.invalidInputData("Negative sleep duration values provided.")
        }
        
        do {
            let input = sleepWellRestednessInput(
                awake: awakeInt,
                core: coreInt,
                deep: deepInt,
                rem: remInt,
                unspecified: unspecifiedInt,
                sleepDuration: sleepDurationInt
            )
            let output = try model.prediction(input: input)
            return output.restedness
        } catch {
            throw RestednessPredictionError.predictionFailed(error)
        }
    }
}
