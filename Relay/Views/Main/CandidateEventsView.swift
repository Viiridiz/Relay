import SwiftUI

fileprivate let brandNavy = Color(red: 27/255, green: 30/255, blue: 89/255)
fileprivate let brandCyan = Color(red: 0.2, green: 0.8, blue: 0.8)

struct CandidateEventsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            brandNavy.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 50)
                    } else if authViewModel.candidateEvents.isEmpty {
                        Text("You haven't joined any events yet.")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 50)
                    } else {
                        ForEach(authViewModel.candidateEvents) { event in
                            EventPillView(event: event)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("My Events")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(brandNavy, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct EventPillView: View {
    let event: Event
    
    private var eventDate: String {
        event.startsAt.formatted(date: .abbreviated, time: .omitted)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.title3)
                .foregroundStyle(brandCyan)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(event.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text(event.jobPosition)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(brandCyan)
                
                Text("\(event.location) · \(eventDate)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
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
    
    let event1 = Event(
        recruiterID: "1",
        name: "Fall Tech Fair",
        location: "Room 101",
        startsAt: Date(),
        endsAt: Date(),
        jobPosition: "Software Engineer"
    )
    
    let event2 = Event(
        recruiterID: "2",
        name: "Spring Career Expo",
        location: "Main Gymnasium",
        startsAt: Date().addingTimeInterval(86400 * 30),
        endsAt: Date(),
        jobPosition: "Data Analyst Intern"
    )
    
    vm.candidateEvents = [event1, event2]
    
    return NavigationStack {
        CandidateEventsView()
            .environmentObject(vm)
    }
}
