//
//  HeartRateViewModel.swift
//  civeng190project
//
//  Created by Ria  Lakkimsetti on 4/20/25.
//


import Foundation

@MainActor
class HeartRateViewModel: ObservableObject {
    @Published var entries: [HeartRateEntry] = []
    @Published var newDescription: String = ""
    @Published var selectedEntryIndex: Int?

    func loadEntries(patientId: String, token: String) async {
        do {
            print("📲 Fetching for patient \(patientId)")
            let result = try await HeartRateService.fetchHeartRates(for: patientId, token: token)
            print("Received JSON: \(result)")
            self.entries = result
            print("Loaded \(result.count) entries into view model")
        } catch {
            print("Error loading heart rate entries: \(error)")
        }
    }

    func updateDescription(for index: Int) {
        entries[index].description = newDescription
        newDescription = ""
    }
}
