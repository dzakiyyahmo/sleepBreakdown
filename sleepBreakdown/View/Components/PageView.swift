//
//  PageView.swift
//  sleepBreakdown
//
//  Created by Dzakiyyah Azahra on 04/06/25.
//

import SwiftUI

struct PageView: View {
    let title: String
    let imageName: String
    let description: String
    let showContinueButton: Bool // To control the last page's button
    let buttonAction: () -> Void // Closure for button action

    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.regular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)

            Spacer()

            Image(imageName)
                .resizable()
                .scaledToFit() // Use scaledToFit for better image scaling
                .frame(width: 245.27, height: 246.33) // Or adjust as needed
                .padding(.horizontal) // Add horizontal padding for images if they are too wide

            Spacer()

            Text(description)
                .multilineTextAlignment(.center)
                .padding(40)

            if showContinueButton {
                Button(action: buttonAction) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .frame(width: 243, height: 50)
                        .background(.blue)
                        .cornerRadius(50)
                }
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    PageView(title: "Welcome!", imageName: "imageonboarding1new", description: "This is a test page for onboarding.", showContinueButton: true) {
        print("Button tapped on preview")
    }
}
