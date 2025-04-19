//
//  loginService.swift
//  civeng190project
//
//  Created by Iyu Lin on 2025/4/18.
//

import Foundation

struct LoginResponse: Codable {
    let token: String
    let userId: Int
    let patientId: String
}

enum LoginError: Error, LocalizedError {
    case invalidCredentials
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Email or password is incorrect."
        case .serverError(let msg):
            return msg
        }
    }
}

class LoginService {
    static func login(email: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "http://localhost:3001/api/users/login") else {
            throw LoginError.serverError("Invalid server URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LoginError.serverError("No response from server")
        }
        
        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(LoginResponse.self, from: data)
        } else if httpResponse.statusCode == 401 {
            throw LoginError.invalidCredentials
        } else {
            let serverMessage = try? JSONDecoder().decode([String: String].self, from: data)
            throw LoginError.serverError(serverMessage?["message"] ?? "Unknown error")
        }
    }
}
