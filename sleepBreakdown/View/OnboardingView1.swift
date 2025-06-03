//
//  OnboardingView.swift
//  sleepBreakdown
//
//  Created by Fazry Rachman Susanto on 03/06/25.
//
import SwiftUI
struct OnboardingView: View {
    var body: some View {
        ZStack{
//            Image("backgroundonboarding")
//                .resizable()
//                .ignoresSafeArea()
            VStack{
                
                Text("Hi,\nWelcome to\nSlepie")
                    .font(.largeTitle)
                    .fontWeight(.regular)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                Image("imageonboarding1new")
                    .resizable()
                    .frame(width:245.27, height: 246.33)
                
                Text("It’s feels like a destiny that you install this app. Let’s learn about it a bit.")
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
    OnboardingView()
}
