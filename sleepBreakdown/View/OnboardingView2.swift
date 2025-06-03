
//
//  OnboardingView.swift
//  sleepBreakdown
//
//  Created by Fazry Rachman Susanto on 03/06/25.
//
import SwiftUI
struct OnboardingView2: View {
    var body: some View {
        ZStack{
//            Image("backgroundonboarding")
//                .resizable()
//                .ignoresSafeArea()
            VStack{
                
                Text("How we\ncalculate your \ndata?")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                Image("imageonboarding2new")
                    .resizable()
                    .frame(width:245, height: 236)
                
                Text("Your data never leaves your device. We process them locally using on-device AI.")
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
    OnboardingView2()
}
