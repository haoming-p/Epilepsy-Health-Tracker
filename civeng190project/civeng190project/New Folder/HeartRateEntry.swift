//
//  HeartRateEntry.swift
//  civeng190project
//
//  Created by Ria  Lakkimsetti on 4/20/25.
//

import Foundation

struct HeartRateAPIResponse: Codable {
    let patientId: String
    let abnormalHeartRates: [HeartRateEntry]
}

struct HeartRateEntry: Identifiable, Codable {
    let id: String
    let value: Int
    let date: String
    let time: String
    let abnormal: Bool

    // Mark local-only variables with `CodingKeys` or `@CodableIgnore` pattern
    var description: String = ""
    var isExpanded: Bool = false

    var bpm: Int { value }

    // Ignore these in decoding/encoding
    private enum CodingKeys: String, CodingKey {
        case id, value, date, time, abnormal
    }
}
