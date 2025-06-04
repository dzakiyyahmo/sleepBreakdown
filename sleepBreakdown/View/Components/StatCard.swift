//
//  Untitled.swift
//  sleepBreakdown
//
//  Created by Dzakiyyah Azahra on 02/06/25.
//

import SwiftUI

struct FontSizes {
    static let h1: CGFloat = 47.78
    static let h2: CGFloat = 39.81
    static let h3: CGFloat = 33.18
    static let h4: CGFloat = 27.65
    static let h5: CGFloat = 23.04
    static let h6: CGFloat = 19.2
    static let p: CGFloat  = 16
    static let sm: CGFloat = 13.33
    static let xsm: CGFloat = 11.11
}

struct ColorPalette {
    static let awake: Color = .init(red: 152/255, green: 180/255, blue: 255/255)
    static let rem: Color = .init(red: 220/255, green: 38/255, blue: 126/255)
    static let core: Color = .init(red: 254/255, green: 97/255, blue: 0/255)
    static let deep: Color = .init(red: 254/255, green: 276/255, blue: 0/255)
    static let unspecified: Color = .init(red: 161/255, green: 219/255, blue: 27/255)
    static let rest: Color = .init(red: 190/255, green: 75/255, blue: 235/255)
}

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




//MARK: --Card in HomeView
struct Card: View {
    var type: String
    var title: String
    var desc: String
    
    var body: some View {
        ZStack  {
            VStack (alignment: .trailing) {
                
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 100, height: 50)
                    .blur(radius: 50)
            }
            
            Rectangle()
                .fill(Color.cyan.opacity(0.2))
                .cornerRadius(10)
            
            
            VStack (alignment:.leading, spacing: 36)  {
                HStack {
                    Spacer()
                    Text(type)
                        .font(.system(size: FontSizes.sm, weight: .semibold))
                }
                
                VStack (alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.system(size: FontSizes.h5, weight: .medium))
                    
                    Text(desc)
                        .font(.system(size: FontSizes.p))
                }
            }.padding(10)
        
        }
        .frame(width: 344)
        .padding(.bottom, 20)
    }
}



//#Preview("StatCard") {
//    VStack(spacing: 20) {
//        StatCard(
//            title: "Average Sleep",
//            value: "7h 30m",
//            icon: "bed.double.fill",
//            color: .blue
//        )
//        
//        StatCard(
//            title: "Deep Sleep",
//            value: "25%",
//            icon: "moon.zzz.fill",
//            color: .purple
//        )
//    }
//    .padding()
//}

#Preview(body: {
    Card(type: "REM", title: "REM", desc: "REM")
        .padding()
    
})
