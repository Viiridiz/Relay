//
//  JoinEventView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import SwiftUI

struct JoinEventView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var eventCode: String = ""
    
    @State private var showingSuccessAlert = false
    @State private var joinedEventName = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Join an Event")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Enter the 6-digit code from the recruiter to check in.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            TextField("A9B1C2", text: $eventCode)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.allCharacters)
                .frame(width: 200)
            
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
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .frame(width: 200)
            
            if authViewModel.isLoading {
                ProgressView()
            }
            
            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .font(.callout)
                    .foregroundStyle(.red)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Join Event")
        .navigationBarTitleDisplayMode(.inline)
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
