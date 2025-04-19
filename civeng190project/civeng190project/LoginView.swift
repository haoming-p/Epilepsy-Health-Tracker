//
//  LoginView.swift
//  civeng190project
//
//  Created by Ria  Lakkimsetti on 4/16/25.
//


import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        if isLoggedIn {
            MainView() // Redirect to your tabbed view
        } else {
            VStack(spacing: 20) {
                Text("Epilepsy Care Login")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Button(action: {
                    // Simulate login
                    isLoggedIn = true
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }
}
