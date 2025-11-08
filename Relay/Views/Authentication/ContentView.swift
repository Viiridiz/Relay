//
//  ContentView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            // user not logged in
            if authViewModel.userSession == nil {
                RoleSelectionView()
                
            } else {
                if let user = authViewModel.currentUser {
                    
                    // we have the user, check role
                    switch user.userRole {
                    case .candidate:
                        MainTabView()
                    case .recruiter:
                        RecruiterMainTabView()
                    }
                    
                } else {
                    // loading
                    ProgressView()
                }
            }
        }
    }
}
#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
