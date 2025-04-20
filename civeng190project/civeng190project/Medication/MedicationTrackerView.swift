//
//  Medication.swift
//  civeng190project
//
//  Created by Ria  Lakkimsetti on 4/6/25.
//

import SwiftUI

struct Medication: Identifiable {
    let id = UUID()
    let name: String
    let dose: String
    let time: String
    var isTaken: Bool = false
}

struct MedicationTrackerView: View {
    @EnvironmentObject var session: UserSession
    @StateObject var viewModel = MedicationViewModel()

    @State private var showingAddMed = false  // Add state to show sheet

    var body: some View {
        VStack(spacing: 20) {
            // Header with date and add buttons
            ZStack {
                Text(todayString())
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddMed = true
                    }) {
                        Image(systemName: "plus.square")
                            .font(.title2)
                            .padding()
                    }
                }
            }
            .padding(.horizontal)

            // Pills Progress
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 200, height: 200)

                VStack {
                    Image(systemName: "pills")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)

                    Text(viewModel.schedules.isEmpty ? "0" : "\(viewModel.schedules.count)")

                        .font(.system(size: 36, weight: .bold))

                    Text("Today")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top)

            // Medication List
            VStack(spacing: 16) {
                ForEach(viewModel.schedules) { schedule in
                    HStack {
                        Image(systemName: "info.circle")
                                        .foregroundColor(.yellow)

                                    VStack(alignment: .leading) {
                                        Text(schedule.name)
                                            .fontWeight(.bold)
                                        Text(schedule.dosage)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                        }

                        Spacer()

                        VStack {
                            ForEach(schedule.times, id: \.self) { time in
                                Text(time)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                    
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemGray6))
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showingAddMed) {
            AddMedicationView(viewModel: viewModel)
        }
        .onAppear {
            Task {
                guard let patientId = session.patientId,
                      let token = session.token else { return }
                await viewModel.loadSchedules(patientId: patientId, token: token)
            }
        }
    }

    
    func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full // Saturday, April 20, 2025
        return formatter.string(from: Date())
    }
    
}



//#Preview {
//    MedicationTrackerView()
//}
