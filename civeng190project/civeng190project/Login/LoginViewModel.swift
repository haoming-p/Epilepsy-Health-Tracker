//
//  LoginViewModel.swift
//  civeng190project
//
//  Created by Iyu Lin on 2025/4/18.
//
import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
//    @Published var isLoggedIn = false
    @Published var loginError: String?
    
    func login(using session: UserSession) async {
        do {
            let response = try await LoginService.login(email: email, password: password)
            session.login(with: response)
//            print("Token: \(response.token)")
//            UserDefaults.standard.set(response.token, forKey: "authToken")
//            UserDefaults.standard.set(response.patientId, forKey: "patientId")
//            isLoggedIn = true
        } catch {
            print("Login failed: \(error.localizedDescription)")
            loginError = error.localizedDescription
        }
    }
}

