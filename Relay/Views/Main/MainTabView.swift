//
//  MainTabView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private var unreadNotificationCount: Int {
        authViewModel.candidateNotifications.filter { !$0.isRead }.count
    }

        var body: some View {
            TabView {
                
                // Tab 1: Profile
                NavigationStack {
                    CandidateHomeView()
                }
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                
                // Tab 2: Join Event
                NavigationStack {
                    JoinEventView()
                }
                .tabItem {
                    Label("Join Event", systemImage: "qrcode.viewfinder")
                }
                
                // Tab 3: My Events
                NavigationStack {
                    CandidateEventsView()
                }
                .tabItem {
                    Label("My Events", systemImage: "calendar")
                }
                
                // Tab 4: Notifications
                NavigationStack {
                    NotificationsView()
                }
                .tabItem {
                    Label("Inbox", systemImage: "bell.fill")
                }
                .badge(unreadNotificationCount)
                
                // Tab 5: Settings 
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
    MainTabView()
        .environmentObject(AuthViewModel())
}
