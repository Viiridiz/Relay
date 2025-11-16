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
                if authViewModel.recruiterProfile != nil {
                    RecruiterProfileView()
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
