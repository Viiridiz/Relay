import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    init() {
        let navy = UIColor(red: 27/255, green: 30/255, blue: 89/255, alpha: 1.0)
        let cyan = UIColor(red: 0.2, green: 0.8, blue: 0.8, alpha: 1.0)
        let inactive = UIColor.white.withAlphaComponent(0.5)
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = navy
        appearance.shadowColor = nil
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = inactive
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: inactive]
        itemAppearance.selected.iconColor = cyan
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: cyan]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private var unreadNotificationCount: Int {
        authViewModel.candidateNotifications.filter { !$0.isRead }.count
    }

    var body: some View {
        TabView {
            NavigationStack {
                CandidateHomeView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
            
            NavigationStack {
                JoinEventView()
            }
            .tabItem {
                Label("Join Event", systemImage: "qrcode.viewfinder")
            }
            
            NavigationStack {
                CandidateEventsView()
            }
            .tabItem {
                Label("My Events", systemImage: "calendar")
            }
            
            NavigationStack {
                NotificationsView()
            }
            .tabItem {
                Label("Inbox", systemImage: "bell.fill")
            }
            .badge(unreadNotificationCount)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .tint(Color(red: 0.2, green: 0.8, blue: 0.8))
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
