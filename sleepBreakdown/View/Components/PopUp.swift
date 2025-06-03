//
//  PopUp.swift
//  sleepBreakdown
//
//  Created by Fazry Rachman Susanto on 06/06/25.
//

import SwiftUI

struct SleepStageInfo: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

struct PopUpView: View {
    @Binding var isPresented: Bool
    let info: SleepStageInfo
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                .onTapGesture { // Close pop-up when tapping outside
                    isPresented = false
                }
            
            VStack(spacing: 15) {
                Text(info.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(info.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                Button("Close") {
                    isPresented = false
                }
                .padding(.top)
            }
            .padding()
            .frame(width: 300)
            .background(.ultraThinMaterial) // Apply blur effect
            .cornerRadius(15)
            .shadow(radius: 20)
        }
    }
}

struct PopUpView_Previews: PreviewProvider {
    static var previews: some View {
        PopUpView(isPresented: .constant(true), info: SleepStageInfo(title: "Awake", description: "It takes time to fall asleep and we wake up periodically throughout the night. This time is represented as \"Awake\" in your charts."))
    }
}

