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
    @State private var selectedDay = 7
    @State private var medications = [
        Medication(name: "Valproate", dose: "1 Capsule", time: "10:00"),
        Medication(name: "B6 Pyridoxine", dose: "5 Drops", time: "12:15")
    ]
    @State private var showingAddMed = false  // ✅ Add state to show sheet

    var body: some View {
        VStack(spacing: 20) {
            // Header with back and add buttons
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .padding()
                }
                Spacer()
                Button(action: {
                    showingAddMed = true  // ✅ Open the AddMedicationView
                }) {
                    Image(systemName: "plus.square")
                        .font(.title2)
                        .padding()
                }
            }

            // Date Selector
            HStack(spacing: 12) {
                ForEach(2...7, id: \.self) { day in
                    VStack {
                        Text("\(day)")
                            .font(.headline)
                        Text(shortDay(for: day))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(selectedDay == day ? Color.blue.opacity(0.1) : Color.clear)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedDay == day ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        selectedDay = day
                    }
                }
            }

            // Pills Progress
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 200, height: 200)

                VStack {
                    Image(systemName: "pills")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)

                    Text("\(medications.filter { $0.isTaken }.count)/\(medications.count)")
                        .font(.system(size: 36, weight: .bold))

                    Text("Today")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top)

            // Medication List
            VStack(spacing: 16) {
                ForEach(medications.indices, id: \.self) { index in
                    HStack {
                        Image(systemName: medications[index].isTaken ? "checkmark.circle.fill" : "info.circle")
                            .foregroundColor(medications[index].isTaken ? .green : .yellow)

                        VStack(alignment: .leading) {
                            Text(medications[index].name)
                                .fontWeight(.bold)
                            Text(medications[index].dose)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Text(medications[index].time)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                    .onTapGesture {
                        medications[index].isTaken.toggle()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemGray6))
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showingAddMed) {
            AddMedicationView()
        } // ✅ Sheet modifier to present AddMedicationView
    }

    func shortDay(for day: Int) -> String {
        switch day {
        case 2: return "RI"
        case 3: return "SAT"
        case 4: return "SUN"
        case 5: return "MON"
        case 6: return "TUE"
        case 7: return "WED"
        default: return ""
        }
    }
}
