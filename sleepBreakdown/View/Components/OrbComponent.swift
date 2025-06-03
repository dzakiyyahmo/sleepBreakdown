//
//  OrbView.swift
//  sleepBreakdown
//
//  Created by Raynanda on 03/06/25.
//

import SwiftUI
import Orb

struct CustomOrbComponent: View {
    let configuration: OrbConfiguration
    let size: CGFloat
    
    // Simple initializer with just the essentials
    init(
        backgroundColors: [Color] = [.yellow, .orange, .red],
        glowColor: Color = .purple,
        particleColor: Color = .white,
        size: CGFloat = 200
    ) {
        self.configuration = OrbConfiguration(
            backgroundColors: backgroundColors,
            glowColor: glowColor,
        )
        self.size = size
    }
    
    // Convenience initializer for preset configurations
    init(preset: OrbPreset, size: CGFloat = 200) {
        self.configuration = preset.configuration
        self.size = size
    }
    
    var body: some View {
        OrbView(configuration: configuration)
            .frame(width: size, height: size)
    }
}

// MARK: - Preset Configurations
enum OrbPreset {
    case ocean
    case cosmic
    case sunset
    
    var configuration: OrbConfiguration {
        switch self {
        case .ocean:
            return OrbConfiguration(
                backgroundColors: [.blue, .cyan, .teal],
                glowColor: .cyan,
                speed: 35
            )
            
        case .cosmic:
            return OrbConfiguration(
                backgroundColors: [.purple, .pink, .blue],
                glowColor: .purple
            )
            
        case .sunset:
            return OrbConfiguration(
                backgroundColors: [.orange, .red, .pink],
                glowColor: .red,
                coreGlowIntensity: 0.8
            )
        }
    }
}

#Preview {
    ScrollView {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
            
            // Using preset configurations
            CustomOrbComponent(preset: .ocean, size: 150)
            CustomOrbComponent(preset: .cosmic, size: 150)
            CustomOrbComponent(preset: .sunset, size: 150)
        }
        .padding()
    }
}
