//
//  SignUpView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//

import SwiftUI

struct SignUpView: View {
    var role: UserAccount.UserRole
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Theme Colors
    let brandNavy = Color(red: 27/255, green: 30/255, blue: 89/255)
    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.85, green: 0.3, blue: 0.6),
            Color(red: 0.4, green: 0.3, blue: 0.8),
            Color(red: 0.2, green: 0.8, blue: 0.8)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            brandNavy.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Text("Sign up as a \(role == .candidate ? "Candidate" : "Recruiter")")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                VStack(spacing: 16) {
  
                    ZStack(alignment: .leading) {
                        if name.isEmpty {
                            Text("Full Name")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.leading, 16)
                        }
                        
                        TextField("", text: $name)
                            .padding()
                            .autocapitalization(.words)
                            .foregroundColor(.white)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    
      
                    ZStack(alignment: .leading) {
                        if email.isEmpty {
                            Text("Email")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.leading, 16)
                        }
                        
                        TextField("", text: $email)
                            .padding()
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .foregroundColor(.white)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    

                    ZStack(alignment: .leading) {
                        if password.isEmpty {
                            Text("Password")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.leading, 16)
                        }
                        
                        SecureField("", text: $password)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white, lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Button(action: {
                        Task {
                            await authViewModel.signUp(
                                email: email,
                                password: password,
                                name: name,
                                role: role
                            )
                        }
                    }) {
                        Text("Sign Up")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(brandGradient)
                            .cornerRadius(30)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                }
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Spacer()
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NavigationStack {
        SignUpView(role: .candidate)
            .environmentObject(AuthViewModel())
    }
}
