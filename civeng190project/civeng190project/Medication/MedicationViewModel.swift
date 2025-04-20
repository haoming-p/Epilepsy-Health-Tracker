//
//  MedicationViewModel.swift
//  civeng190project
//
//  Created by Iyu Lin on 2025/4/19.
//
import Foundation


@MainActor
class MedicationViewModel: ObservableObject {
    @Published var medicationName = ""
    @Published var pillCount = ""
    @Published var notificationTimes: [Date] = []
    @Published var schedules: [MedicationSchedule] = []

    func submitMedication(for patientId: String, token: String) async {
        do {
            let newSchedule = try await MedicationAPIService.shared.createScheduleAndReturn(
                patientId: patientId,
                medicationName: medicationName,
                dosage: "\(pillCount) pills",
                timing: notificationTimes.map { $0.toTimeString() },
                token: token
            )
            schedules.insert(newSchedule, at: 0)
            print("Medication schedule submitted and appended!")
        } catch {
            print("Failed to create schedule:", error)
        }
    }
    
    func loadSchedules(patientId: String, token: String) async {
        do {
            print("Loading schedules from backend...")
            let fetched = try await MedicationAPIService.shared.fetchSchedules(patientId: patientId, token: token)
            print("Fetched \(fetched.count) schedules")
            self.schedules = fetched
        } catch {
            print("Failed to load schedules:", error)
        }
    }
}
