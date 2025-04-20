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
    var description: String
    var isExpanded: Bool = false
}

struct ContentView: View {
    @State private var entries: [SeizureEntry] = []
    @State private var newDescription = ""
    @State private var selectedEntryIndex: Int?

    // Get today's date in YYYY.MM.DD format
    var todaysDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header background only
            Color.blue
                .frame(height: 80)
                .ignoresSafeArea(edges: .top)

            // Seizure Diary Title
            HStack {
                Text("Seizure Diary")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding()

            // Today's Entry Input
            VStack(alignment: .leading, spacing: 10) {
                Text("Add Description for Today (\(todaysDate)):")
                    .bold()
                TextField("Enter description...", text: $newDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Submit") {
                    guard !newDescription.isEmpty else { return }

                    // Prevent duplicate entries for today
                    if !entries.contains(where: { $0.date == todaysDate }) {
                        let newEntry = SeizureEntry(date: todaysDate, bpm: 140, description: newDescription)
                        entries.insert(newEntry, at: 0)
                        newDescription = ""
                    }
                }
                .padding(.top, 5)
            }
            .padding(.horizontal)

            Divider()

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
                                        selectedEntryIndex = entries[i].isExpanded ? i : nil
                                        newDescription = entries[i].description
                                    }) {
                                        Image(systemName: entries[i].isExpanded ? "chevron.up" : "chevron.down")
                                    }
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(15)

                            if entries[i].isExpanded {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Description:")
                                        .bold()
                                    Text(entries[i].description.isEmpty ? "No details provided." : entries[i].description)
                                        .fixedSize(horizontal: false, vertical: true)

                                    // Edit + Update
                                    TextField("Update description...", text: $newDescription)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())

                                    Button("Update") {
                                        if let selected = selectedEntryIndex {
                                            entries[selected].description = newDescription
                                            newDescription = ""
                                        }
                                    }
                                    .padding(.top, 5)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .animation(.easeInOut, value: entries[i].isExpanded)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            // TODO: Integrate backend API: GET /heart-rates/patient/:patientId
        }
    }
}
