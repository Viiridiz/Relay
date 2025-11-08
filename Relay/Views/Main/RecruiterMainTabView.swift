//
//  RecruiterMainTabView.swift
//  Relay
//
//  Created by user286649 on 11/8/25.
//
import SwiftUI

struct RecruiterMainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            // tab 1: events
            NavigationStack {
                RecruiterEventsView()
            }
            .tabItem {
                Label("Events", systemImage: "calendar")
            }
            
            // tab 2: profile
            NavigationStack {
                // show spinner or profile
                if let profile = authViewModel.recruiterProfile {
                    VStack {
                        Text("Welcome, \(profile.name)")
                            .font(.largeTitle)
                        Text(profile.email)
                        // todo: add profile edit
                        Spacer()
                    }
                    .padding()
                    .navigationTitle("Profile")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Sign Out") {
                                authViewModel.signOut()
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
        }
    }
}

#Preview {
    RecruiterMainTabView()
        .environmentObject(AuthViewModel())
}
