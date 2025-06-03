//
//  OnboardingView3.swift
//  sleepBreakdown
//
//  Created by Fazry Rachman Susanto on 03/06/25.
//

//
//  OnboardingView.swift
//  sleepBreakdown
//
//  Created by Fazry Rachman Susanto on 03/06/25.
//
import SwiftUI
struct OnboardingView3: View {
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
                
                Image("imageonboarding3new")
                    .resizable()
                    .frame(width:302, height: 242)
                
                Text("It roughly estimates your energy level on wake-up. Consult physician if you have any concerns.")
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
    OnboardingView3()
}

