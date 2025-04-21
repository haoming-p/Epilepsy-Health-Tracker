//
//  HeartRateService.swift
//  civeng190project
//
//  Created by Ria  Lakkimsetti on 4/20/25.
//


import Foundation

class HeartRateService {
    static func fetchHeartRates(for patientId: String, token: String) async throws -> [HeartRateEntry] {
        let urlString = "http://localhost:3001/api/heartRate/\(patientId)/abnormal"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        // 🔍 Print raw JSON to Xcode console
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON from backend:\n\(jsonString)")
        } else {
            print("Could not convert data to string.")
        }

        let decodedResponse = try JSONDecoder().decode(HeartRateAPIResponse.self, from: data)
        return decodedResponse.abnormalHeartRates
    }
}

