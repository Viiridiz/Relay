//
//  NotificationsView.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            if authViewModel.candidateNotifications.isEmpty {
                Text("No notifications yet.")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else {
                List(authViewModel.candidateNotifications) { notification in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Message from \(notification.recruiterName)")
                            .font(.headline)
                        Text(notification.message)
                            .font(.callout)
                            .foregroundStyle(.primary)
                        Text("\(notification.companyName) · \(notification.jobPosition)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Notifications")
    }
}

#Preview {
    let vm = AuthViewModel()
    vm.candidateNotifications = [
        Notification(candidateID: "1", recruiterName: "Jane Doe", companyName: "Google", jobPosition: "Intern", message: "We'd like to move forward!")
    ]
    return NavigationStack {
        NotificationsView()
            .environmentObject(vm)
    }
}
