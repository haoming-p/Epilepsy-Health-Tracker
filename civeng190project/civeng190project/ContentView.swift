//
//  ContentView.swift
//  civeng190project
//
//  Created by Ria  Lakkimsetti on 4/5/25.
//

import SwiftUI

struct SeizureEntry: Identifiable {
    let id = UUID()
    let date: String
    let bpm: Int
    let description: String
    var isExpanded: Bool = false
}

struct ContentView: View {
    @State private var searchText = ""
    @State private var entries = [
        SeizureEntry(date: "2025.03.05", bpm: 150, description: "Description for March 5 seizure."),
        SeizureEntry(date: "2025.02.28", bpm: 120, description: ""),
        SeizureEntry(date: "2025.02.17", bpm: 130, description: ""),
        SeizureEntry(date: "2025.01.31", bpm: 125, description: ""),
        SeizureEntry(date: "2025.01.15", bpm: 140, description: ""),
        SeizureEntry(date: "2025.01.03", bpm: 135, description: ""),
        SeizureEntry(date: "2024.12.20", bpm: 145, description: "")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 10) {
                Text("Hello,")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("John")
                    .font(.title3)
                    .foregroundColor(.white)

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search Date...", text: $searchText)
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
            }
            .padding()
            .background(Color.blue)

            // Seizure Diary Title
            HStack {
                Text("Seizure Diary")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding()

            // Seizure Entries
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(entries.indices, id: \.self) { i in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(entries[i].date)
                                Spacer()
                                HStack {
                                    if entries[i].isExpanded {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                        Text("\(entries[i].bpm) bpm")
                                    }
                                    Button(action: {
                                        entries[i].isExpanded.toggle()
                                    }) {
                                        Image(systemName: entries[i].isExpanded ? "chevron.up" : "chevron.down")
                                    }
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(15)

                            if entries[i].isExpanded {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Description:")
                                        .bold()
                                    Text(entries[i].description.isEmpty ? "No details provided." : entries[i].description)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .animation(.easeInOut, value: entries[i].isExpanded)
                    }
                }
                .padding(.horizontal)
            }

            // Bottom Navigation
            HStack {
                Spacer()
                Image(systemName: "house.fill")
                Spacer()
                Image(systemName: "ellipsis.circle.fill")
                Spacer()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding(.bottom, 10)
        }
        .ignoresSafeArea(edges: .top)
    }
}
