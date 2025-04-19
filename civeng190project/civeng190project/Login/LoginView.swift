//
//  LoginView.swift
//  civeng190project
//
//  Created by Ria  Lakkimsetti on 4/16/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        if viewModel.isLoggedIn {
            MainView()
        } else {
            VStack(spacing: 20) {
                Text("Epilepsy Care Login")
                    .font(.largeTitle)
                    .bold()

                TextField("Email", text: $viewModel.email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .autocapitalization(.none)

                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                if let error = viewModel.loginError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button(action: {
                    Task {
                        await viewModel.login()
                    }
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
