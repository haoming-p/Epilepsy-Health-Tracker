//
//  HeartRateView.swift
//  civeng190project
//
//  Created by Ria  Lakkimsetti on 4/10/25.
//


import SwiftUI

struct HeartRateView: View {
    // Placeholder for actual heart rate data
    @State private var heartRate: Int = 72

    var body: some View {
        VStack(spacing: 30) {
            Text("Live Heart Rate")
                .font(.title)
                .fontWeight(.bold)

            Text("\(heartRate) BPM")
                .font(.system(size: 60, weight: .semibold))
                .foregroundColor(.red)

            Text("Monitoring via Apple Watch")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding()
    }
}

struct HeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateView()
    }
}