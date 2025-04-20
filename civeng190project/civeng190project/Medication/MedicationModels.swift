//
//  MedicationModels.swift
//  civeng190project
//
//  Created by Iyu Lin on 2025/4/19.
//

import Foundation

struct MedicationSchedule: Identifiable {
    let id: String
    let name: String
    let dosage: String
    let times: [String]
}

struct FHIRBundle: Decodable {
    let entry: [FHIRBundleEntry]
}

struct FHIRBundleEntry: Decodable {
    let resource: MedicationRequestResource
}

struct MedicationScheduleResponse: Decodable {
    let message: String
    let requestId: String
    let request: MedicationRequestResource
}

struct MedicationRequestResource: Decodable {
    let id: String
    let medicationReference: MedicationReference
    let dosageInstruction: [DosageInstruction]
}

struct MedicationReference: Decodable {
    let display: String
}

struct DosageInstruction: Decodable {
    let text: String?
    let timing: Timing?
}

struct Timing: Decodable {
    let `repeat`: TimingRepeat?
}

struct TimingRepeat: Decodable {
    let timeOfDay: [String]?
}
