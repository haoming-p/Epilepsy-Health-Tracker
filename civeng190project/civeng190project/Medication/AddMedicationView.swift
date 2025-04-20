//
//  AddMedicationView.swift
//  civeng190project
//
//  Created by Ria  Lakkimsetti on 4/6/25.
//


import SwiftUI

struct AddMedicationView: View {
    @EnvironmentObject var session: UserSession
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MedicationViewModel

    @State private var showingTimePicker = false
    @State private var newNotificationTime = Date()
    @State private var isSubmitting = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Medication Name")
                            .fontWeight(.semibold)
                        TextField("Enter medication name", text: $viewModel.medicationName)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }

                    Group {
                        Text("Dosage")
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 16) {
                            HStack {
                                Image(systemName: "pills")
                                    .padding(.trailing, 10)
                                TextField("Dosage", text: $viewModel.pillCount)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }

                    Group {
                        Text("Schedule")
                            .fontWeight(.semibold)
                        ForEach(viewModel.notificationTimes.indices, id: \.self) { i in
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.blue)
                                Text(viewModel.notificationTimes[i], style: .time)
                                Spacer()
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }

                        Button(action: {
                            showingTimePicker = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Time")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                        }
                    }

                    Button(action: {
                        // Save logic goes here
                        Task {
                            guard let token = session.token,
                                          let patientId = session.patientId else { return }
                            isSubmitting = true
                            await viewModel.submitMedication(for: patientId, token: token)
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            isSubmitting = false
                            dismiss()
                        }
                        
                    }) {
                        Text(isSubmitting ? "Submitting..." : "Submit")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(isSubmitting)
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Add Med Plan")
            .sheet(isPresented: $showingTimePicker) {
                VStack(spacing: 20) {
                    Text("Set Time for Alarm")
                        .font(.headline)

                    DatePicker("Select Time", selection: $newNotificationTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()

                    HStack {
                        Button("Cancel") {
                            showingTimePicker = false
                        }
                        .foregroundColor(.red)

                        Spacer()

                        Button("Save") {
                            viewModel.notificationTimes.append(newNotificationTime)
                            showingTimePicker = false
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .presentationDetents([.fraction(0.4)])
            }
        }
    }
}


