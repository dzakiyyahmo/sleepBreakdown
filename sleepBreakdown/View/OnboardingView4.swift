//
//  OnboardingView4.swift
//  sleepBreakdown
//
//  Created by Fazry Rachman Susanto on 03/06/25.
//

import SwiftUI
struct OnboardingView4: View {
    var body: some View {
        ZStack{
//            Image("backgroundonboarding")
//                .resizable()
//                .ignoresSafeArea()
            VStack{
                
                Text("What does restedness-score \nmean?")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                Image("imageonboarding4new")
                    .resizable()
                    .frame(width:283, height: 304)
                
                Text("Your watch provides more detailed data your iPhone doesn’t. Without such data, we cannot make calculation to estimate your restedness score.")
                    .multilineTextAlignment(.center)
                    .padding(20)
                
                Text("Continue")
                    .foregroundColor(.white)
                    .frame(width: 243, height: 50)
                    .background(.blue)
                    .cornerRadius(50)
                    .padding(.top, 60)
            }
          
            
        }
        
        
    }
}

#Preview {
    OnboardingView4()
}

