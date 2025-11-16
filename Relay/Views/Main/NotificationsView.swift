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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if authViewModel.candidateNotifications.isEmpty {
                    Text("No notifications yet.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 50)
                } else {
                    ForEach(authViewModel.candidateNotifications) { notification in
                        NotificationPillView(notification: notification)
                            .onTapGesture {
                                // mark as read on tap
                                if !notification.isRead, let notificationID = notification.id {
                                    Task {
                                        await authViewModel.markNotificationAsRead(notificationID: notificationID)
                                    }
                                }
                            }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Notifications")
    }
}

struct NotificationPillView: View {
    let notification: Notification
    
    var body: some View {
        HStack(spacing: 16) {
            // unread indicator
            Circle()
                .fill(notification.isRead ? Color.clear : Color.blue)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Message from \(notification.recruiterName)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(notification.message)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                
                Text("\(notification.companyName) · \(notification.jobPosition)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}


#Preview {
    let vm = AuthViewModel()
    
    // create a mix of read and unread
    var readNotification = Notification(
        candidateID: "1",
        recruiterName: "Jane Doe",
        companyName: "Google",
        jobPosition: "Intern",
        message: "We'd like to move forward!"
    )
    readNotification.isRead = true
    
    let unreadNotification = Notification(
        candidateID: "2",
        recruiterName: "John Smith",
        companyName: "Apple",
        jobPosition: "Software Engineer",
        message: "Your profile is a great fit for the Software Engineer role we're hiring for."
    )
    
    vm.candidateNotifications = [unreadNotification, readNotification]
    
    return NavigationStack {
        NotificationsView()
            .environmentObject(vm)
    }
}
