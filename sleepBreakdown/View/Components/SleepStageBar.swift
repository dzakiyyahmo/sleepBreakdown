//
//  SleepStageBar.swift
//  sleepBreakdown
//
//  Created by Dzakiyyah Azahra on 02/06/25.
//
import SwiftUI

//MARK: -- SleepStageBar
struct SleepStageBar: View {
    let rem: TimeInterval
    let core: TimeInterval
    let deep: TimeInterval
    let awake: TimeInterval
    
    private var total: TimeInterval {
        rem + core + deep + awake
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.purple)
                    .frame(width: geometry.size.width * CGFloat(rem / max(total, 1)))
                
                Rectangle()
                    .fill(Color.indigo)
                    .frame(width: geometry.size.width * CGFloat(core / max(total, 1)))
                
                Rectangle()
                    .fill(Color.teal)
                    .frame(width: geometry.size.width * CGFloat(deep / max(total, 1)))
                
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: geometry.size.width * CGFloat(awake / max(total, 1)))
            }
            .cornerRadius(4)
        }
    }
}

#Preview("SleepStageBar") {
    VStack(spacing: 30) {
        // Balanced sleep distribution
        SleepStageBar(
            rem: 2 * 3600,    // 2 hours
            core: 4 * 3600,   // 4 hours
            deep: 2 * 3600,    // 2 hours
            awake: 1 * 3600
        )
        .frame(height: 8)
        
        // More REM sleep
        SleepStageBar(
            rem: 3 * 3600,    // 3 hours
            core: 3 * 3600,   // 3 hours
            deep: 1 * 3600,    // 1 hour
            awake: 1 * 3600
        )
        .frame(height: 8)
        
        // More deep sleep
        SleepStageBar(
            rem: 1.5 * 3600,  // 1.5 hours
            core: 3.5 * 3600, // 3.5 hours
            deep: 3 * 3600,    // 3 hours
            awake: 1 * 3600
        )
        .frame(height: 8)
    }
    .padding()
}
