import SwiftUI

fileprivate let brandNavy = Color(red: 27/255, green: 30/255, blue: 89/255)
fileprivate let brandCyan = Color(red: 0.2, green: 0.8, blue: 0.8)
fileprivate let brandGradient = LinearGradient(
    colors: [
        Color(red: 0.85, green: 0.3, blue: 0.6),
        Color(red: 0.4, green: 0.3, blue: 0.8),
        Color(red: 0.2, green: 0.8, blue: 0.8)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

struct RecruiterEventsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingCreateSheet = false
    
    var body: some View {
        ZStack {
            brandNavy.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    if authViewModel.recruiterEvents.isEmpty {
                        Text("No events created yet.")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 50)
                    } else {
                        ForEach(authViewModel.recruiterEvents) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                RecruiterEventCard(event: event)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Your Events")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(brandNavy, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showingCreateSheet = true
                }) {
                    Image(systemName: "plus")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateEventView()
        }
    }
}

struct RecruiterEventCard: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .center, spacing: 4) {
                Image(systemName: "qrcode")
                    .font(.title2)
                    .foregroundStyle(brandCyan)
                
                Text(event.eventCode ?? "---")
                    .font(.caption.bold())
                    .fontDesign(.monospaced)
                    .foregroundStyle(.white)
            }
            .frame(width: 60)
            .padding(.trailing, 8)
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1)
                    .padding(.vertical, 4),
                alignment: .trailing
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(event.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text(event.location)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                
                HStack {
                    Text(event.jobPosition)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(brandCyan)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        RecruiterEventsView()
            .environmentObject(AuthViewModel())
    }
}
