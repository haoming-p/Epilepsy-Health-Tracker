//
//  MainView.swift
//  civeng190project
//
//  Created by Ria  Lakkimsetti on 4/6/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var session: UserSession
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            MedicationTrackerView()
                .tabItem {
                    Image(systemName: "pills.fill")
                    Text("Medication")
                }

            HeartRateView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Heart Rate")
                }
        }
    }
}
