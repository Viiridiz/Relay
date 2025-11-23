import SwiftUI

fileprivate let brandNavy = Color(red: 27/255, green: 30/255, blue: 89/255)
fileprivate let brandCyan = Color(red: 0.2, green: 0.8, blue: 0.8)

struct NotificationsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            brandNavy.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if authViewModel.candidateNotifications.isEmpty {
                        Text("No notifications yet.")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 50)
                    } else {
                        ForEach(authViewModel.candidateNotifications) { notification in
                            NotificationPillView(notification: notification)
                                .onTapGesture {
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
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(brandNavy, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct NotificationPillView: View {
    let notification: Notification
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(notification.isRead ? Color.clear : brandCyan)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Message from \(notification.recruiterName)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text(notification.message)
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(3)
                
                Text("\(notification.companyName) · \(notification.jobPosition)")
                    .font(.caption)
                    .foregroundStyle(brandCyan)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(15)
    }
}


#Preview {
    let vm = AuthViewModel()
    
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
