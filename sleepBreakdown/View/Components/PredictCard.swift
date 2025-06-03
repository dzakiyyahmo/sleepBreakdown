//
//  PredictCardScoreDesc.swift
//  sleepBreakdown
//
//  Created by Fazry Rachman Susanto on 02/06/25.
//

import SwiftUI
struct PredictCard: View {
    var body: some View {
        ZStack{
            Image("firecard")
                .resizable()
                .frame(width: 326, height: 126)
        }
    }
}

#Preview {
    PredictCard()
}
