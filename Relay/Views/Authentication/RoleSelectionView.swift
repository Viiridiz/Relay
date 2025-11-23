//
//  RoleSelectionView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//

import SwiftUI

struct RoleSelectionView: View {
    let brandNavy = Color(red: 27/255, green: 30/255, blue: 89/255)
    

    let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.85, green: 0.3, blue: 0.6), // Pink
            Color(red: 0.4, green: 0.3, blue: 0.8),  // Purple
            Color(red: 0.2, green: 0.8, blue: 0.8)   // Cyan
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                brandNavy
                    .ignoresSafeArea()
                
                // 2. Main Content
                VStack(spacing: 40) {
                    
                    // --- LOGO SECTION ---
                    VStack(spacing: 16) {

                        Image("relay_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400)
                        
                        Text("Find your next opportunity or your next great hire.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 60)
                    
                    // --- BUTTONS SECTION ---
                    VStack(spacing: 20) {
                        
                        NavigationLink(value: UserAccount.UserRole.candidate) {
                            Text("I'm a Candidate")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(brandGradient)
                                .cornerRadius(30)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        
                        NavigationLink(value: UserAccount.UserRole.recruiter) {
                            Text("I'm a Recruiter")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                                )
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // --- LOGIN LINK ---
                    NavigationLink(destination: LoginView()) {
                        HStack {
                            Text("Already have an account?")
                                .foregroundStyle(.white.opacity(0.7))
                            Text("Log In")
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        .font(.footnote)
                    }
                    
                    Spacer()
                }
            }
           
            .navigationDestination(for: UserAccount.UserRole.self) { role in
                SignUpView(role: role)
            }
        }
        
        .preferredColorScheme(.dark)
    }
}

#Preview {
    RoleSelectionView()
}
