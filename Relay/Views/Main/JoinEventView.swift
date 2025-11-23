//
//  JoinEventView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import SwiftUI

fileprivate let brandNavy = Color(red: 27/255, green: 30/255, blue: 89/255)
fileprivate let brandGradient = LinearGradient(
    colors: [
        Color(red: 0.85, green: 0.3, blue: 0.6),
        Color(red: 0.4, green: 0.3, blue: 0.8),
        Color(red: 0.2, green: 0.8, blue: 0.8)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

struct JoinEventView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var eventCode: String = ""
    
    @State private var showingSuccessAlert = false
    @State private var joinedEventName = ""
    
    var body: some View {
        ZStack {
            brandNavy.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 10) {
                    Text("Join an Event")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Text("Enter the 6-digit code from the recruiter to check in.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Custom Ghost Input
                TextField("", text: $eventCode, prompt: Text("A9B1C2").foregroundColor(.white.opacity(0.3)))
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(width: 240)
                    .background(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .cornerRadius(12)
                    .autocapitalization(.allCharacters)
                
                Button(action: {
                    Task {
                        let event = await authViewModel.joinEvent(eventCode: eventCode)
                        if let event = event {
                            self.joinedEventName = event.name
                            self.showingSuccessAlert = true
                            self.eventCode = ""
                        }
                    }
                }) {
                    Text("Join Event")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(width: 200)
                        .padding()
                        .background(brandGradient)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .disabled(authViewModel.isLoading)
                .opacity(authViewModel.isLoading ? 0.7 : 1)
                
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                }
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(red: 1.0, green: 0.4, blue: 0.4))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Join Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(brandNavy, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Successfully Joined!", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("You are checked in for the event: \(joinedEventName)")
        }
    }
}

#Preview {
    NavigationStack {
        JoinEventView()
            .environmentObject(AuthViewModel())
    }
}
