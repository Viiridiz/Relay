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
            
            // tab 2: new dashboard
            NavigationStack {
                DecisionDashboardView()
            }
            .tabItem {
                Label("Interested", systemImage: "star.fill")
            }
            
            // tab 3: profile
            NavigationStack {
                // show spinner or profile
                if let profile = authViewModel.recruiterProfile {
                    VStack {
                        Text("Welcome, \(profile.name)")
                            .font(.largeTitle)
                        Text(profile.email)
                        Spacer()
                    }
                    .padding()
                    .navigationTitle("Profile")
                    // removed signout button, its in settings
                } else {
                    ProgressView()
                }
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
            
            // Tab 4: Settings
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

#Preview {
    RecruiterMainTabView()
        .environmentObject(AuthViewModel())
}
