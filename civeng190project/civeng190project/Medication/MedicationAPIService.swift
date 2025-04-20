//
//  MedicationAPIService.swift
//  civeng190project
//
//  Created by Iyu Lin on 2025/4/19.
//

import Foundation

struct MedicationScheduleRequest: Codable {
    let patientId: String
    let medicationName: String
    let dosage: String
    let frequency: Int
    let timing: [String]
    let startDate: String
    let notes: String?
    let periodValue: Int
    let periodUnit: String
}

class MedicationAPIService {
    static let shared = MedicationAPIService()

    func createScheduleAndReturn(
        patientId: String,
        medicationName: String,
        dosage: String,
        timing: [String],
        token: String
    ) async throws -> MedicationSchedule {
        guard let url = URL(string: "http://localhost:3001/api/medications/schedule") else {
            throw URLError(.badURL)
        }

        let requestBody = MedicationScheduleRequest(
            patientId: patientId,
            medicationName: medicationName,
            dosage: dosage,
            frequency: 1,
            timing: timing,
            startDate: Date().toDateString(),
            notes: nil,
            periodValue: 1,
            periodUnit: "d"
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(MedicationScheduleResponse.self, from: data)

        let r = decoded.request
        return MedicationSchedule(
            id: r.id,
            name: r.medicationReference.display,
            dosage: r.dosageInstruction.first?.text ?? "No info",
            times: r.dosageInstruction.first?.timing?.repeat?.timeOfDay ?? []
        )
    }
    func createSchedule(
        patientId: String,
        medicationName: String,
        dosage: String,
        timing: [String],
        token: String
    ) async throws {
        guard let url = URL(string: "http://localhost:3001/api/medications/schedule") else { return }

        let requestBody = MedicationScheduleRequest(
            patientId: patientId,
            medicationName: medicationName,
            dosage: dosage,
            frequency: 1,
            timing: timing,
            startDate: Date().toDateString(),
            notes: nil,
            periodValue: 1,
            periodUnit: "d"
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    func fetchSchedules(patientId: String, token: String) async throws -> [MedicationSchedule] {
        guard let url = URL(string: "http://localhost:3001/api/medications/schedule/\(patientId)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let bundle = try JSONDecoder().decode(FHIRBundle.self, from: data)
        return bundle.entry.map {
            let r = $0.resource
            return MedicationSchedule(
                id: r.id,
                name: r.medicationReference.display,
                dosage: r.dosageInstruction.first?.text ?? "No info",
                times: r.dosageInstruction.first?.timing?.repeat?.timeOfDay ?? []

            )
        }
    }
}
