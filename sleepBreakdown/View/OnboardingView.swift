
//
//  OnboardingView.swift
//  sleepBreakdown
//
//  Created by Fazry Rachman Susanto on 03/06/25.
//
import SwiftUI

struct OnboardingView: View {
    @Binding var hasOnboarded: Bool // Keep this binding for dismissal
    @State private var currentPage: Int = 0 // Track the current page index

    var body: some View {
        NavigationStack {
            ZStack {
                // Background image (uncomment if you want to use it)
                // Image("backgroundonboarding")
                //     .resizable()
                //     .ignoresSafeArea()

                VStack {
                    TabView(selection: $currentPage) {
                        // Page 1
                        PageView(
                            title: "Hi,\nWelcome to\nSlepie",
                            imageName: "imageonboarding1new",
                            description: "It’s feels like a destiny that you install this app. Let’s learn about it a bit.",
                            showContinueButton: true // Show button on this page
                        ) {
                            // Action for the "Continue" button on Page 1
                            currentPage = 1 // Go to the next page (index 1)
                        }
                        .tag(0) // Assign a tag to this view for TabView selection

                        // Page 2 (Example - add more as needed)
                        PageView(
                            title: "How we\ncalculate your \ndata?",
                            imageName: "imageonboarding2new", // Replace with your second image
                            description: "Your data never leaves your device. We process them locally using on-device AI.",
                            showContinueButton: true // Show button on this page
                        ) {
                            // Action for the "Continue" button on Page 2
                            currentPage = 2 // Go to the next page (index 2)
                        }
                        .tag(1) // Tag for the second page

                        // Third Page
                        PageView(
                            title: "What does restedness-score \nmean?",
                            imageName: "imageonboarding3new", // Replace with your third image
                            description: "It roughly estimates your energy level on wake-up. Consult physician if you have any concerns.",
                            showContinueButton: true // Show button on this page
                        ) {
                            // Action for the "Continue" button on the LAST page
                            currentPage = 3 // Set hasOnboarded to true to dismiss the onboarding flow
                        }
                        .tag(2) // Third Page
                        
                        // Last Page
                        PageView(
                            title: "Don't forget \nto use Apple Watch",
                            imageName: "imageonboarding4new", // Replace with your third image
                            description: "Your watch provides more detailed data your iPhone doesn’t. Without such data, we cannot make calculation to estimate your restedness score.",
                            showContinueButton: true // Show button on this page
                        ) {
                            // Action for the "Continue" button on the LAST page
                            hasOnboarded = true // Set hasOnboarded to true to dismiss the onboarding flow
                        }
                        .tag(3) // Tag for the last page
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always)) // Show dots for pagination
                    .indexViewStyle(.page(backgroundDisplayMode: .always)) // Make dots always visible
                    .animation(.easeInOut, value: currentPage) // Smooth animation for page transitions
                }
            }
        }
    }
}

#Preview {
    // For preview, provide a constant binding for hasOnboarded
    OnboardingView(hasOnboarded: .constant(false))
}
