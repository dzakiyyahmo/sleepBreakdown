//
//  Untitled.swift
//  sleepBreakdown
//
//  Created by Dzakiyyah Azahra on 02/06/25.
//

import SwiftUI

//MARK: -- StatCard
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview("StatCard") {
    VStack(spacing: 20) {
        StatCard(
            title: "Average Sleep",
            value: "7h 30m",
            icon: "bed.double.fill",
            color: .blue
        )
        
        StatCard(
            title: "Deep Sleep",
            value: "25%",
            icon: "moon.zzz.fill",
            color: .purple
        )
    }
    .padding()
}
