//
//  AddMedicationView.swift
//  civeng190project
//
//  Created by Ria  Lakkimsetti on 4/6/25.
//


import SwiftUI

struct AddMedicationView: View {
    @State private var pillName = "Valproate"
    @State private var pillCount = 2
    @State private var duration = 7
    @State private var medicalNote = "Lorem ipsum dolor sit amet..."
    @State private var notificationTimes: [Date] = [Date()]
    @State private var showingTimePicker = false
    @State private var newNotificationTime = Date()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Pills Name")
                            .fontWeight(.semibold)
                        TextField("Enter pill name", text: $pillName)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }

                    Group {
                        Text("Amount & Duration")
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 16) {
                            HStack {
                                Image(systemName: "capsule")
                                TextField("Pills", value: $pillCount, formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                                    .frame(width: 50)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                            
                            HStack {
                                Image(systemName: "calendar")
                                TextField("Days", value: $duration, formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                                    .frame(width: 50)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }

                    Group {
                        Text("Medical Order")
                            .fontWeight(.semibold)
                        TextEditor(text: $medicalNote)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(10)
                    }

                    Group {
                        Text("Notification")
                            .fontWeight(.semibold)
                        ForEach(notificationTimes.indices, id: \.self) { i in
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.blue)
                                Text(notificationTimes[i], style: .time)
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
                                Text("Add Notification Time")
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
                    }) {
                        Text("Done")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
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
                            notificationTimes.append(newNotificationTime)
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
