//
//  UserSession.swift
//  civeng190project
//
//  Created by Iyu Lin on 2025/4/19.
//

import Foundation

@MainActor
class UserSession: ObservableObject {
    @Published var token: String?
    @Published var patientId: String?
    @Published var isLoggedIn: Bool = false

    func login(with response: LoginResponse) {
        self.token = response.token
        self.patientId = response.patientId
        self.isLoggedIn = true
    }

    func logout() {
        token = nil
        patientId = nil
        isLoggedIn = false
    }
}
