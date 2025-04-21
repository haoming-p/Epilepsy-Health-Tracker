//
//  ContentView.swift
//  civeng190project
//
//  Created by Ria  Lakkimsetti on 4/5/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: UserSession
    @StateObject private var viewModel = HeartRateViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerBackground

            HStack {
                Text("Seizure Diary")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding()

            if viewModel.entries.isEmpty {
                Text("No heart rate entries found.")
                    .foregroundColor(.gray)
                    .padding()
            }

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.entries.indices, id: \ .self) { i in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(viewModel.entries[i].date)
                                    Text(viewModel.entries[i].time)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()
                                HStack {
                                    if viewModel.entries[i].isExpanded {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                        Text("\(viewModel.entries[i].bpm) bpm")
                                    }
                                    Button(action: {
                                        viewModel.entries[i].isExpanded.toggle()
                                        viewModel.selectedEntryIndex = viewModel.entries[i].isExpanded ? i : nil
                                        viewModel.newDescription = viewModel.entries[i].description
                                    }) {
                                        Image(systemName: viewModel.entries[i].isExpanded ? "chevron.up" : "chevron.down")
                                    }
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(15)

                            if viewModel.entries[i].isExpanded {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Description:")
                                        .bold()
                                    Text(viewModel.entries[i].description.isEmpty ? "No details provided." : viewModel.entries[i].description)
                                        .fixedSize(horizontal: false, vertical: true)

                                    TextField("Update description...", text: $viewModel.newDescription)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())

                                    Button("Submit") {
                                        viewModel.updateDescription(for: i)
                                    }
                                    .padding(.top, 5)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .animation(.easeInOut, value: viewModel.entries[i].isExpanded)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            Task {
                guard let token = session.token,
                      let patientId = session.patientId else {
                    print("Missing session data")
                    return
                }
                await viewModel.loadEntries(patientId: patientId, token: token)
            }
        }
    }

    var headerBackground: some View {
        Color.blue
            .frame(height: 80)
            .ignoresSafeArea(edges: .top)
    }
}
