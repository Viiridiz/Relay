//
//  EventDetailView.swift
//  Relay
//
//  Created by user286649 on 11/8/25.
//
import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(event.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(event.location)
                .font(.title2)
                .foregroundStyle(.secondary)
            
            VStack {
                Text("EVENT CODE")
                    .font(.caption)
                Text(event.eventCode ?? "NO CODE")
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundStyle(.blue)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            Divider()
                .padding(.vertical)
            
            Text("Checked-in Candidates")
                .font(.headline)
            
            List(authViewModel.currentEventAttendees) { candidate in
                NavigationLink(value: candidate) {
                    Text(candidate.name)
                }
            }
            .listStyle(.plain)
            .navigationDestination(for: Candidate.self) { candidate in
                CandidateProfileDetailView(candidate: candidate)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let eventID = event.id {
                Task {
                    await authViewModel.fetchEventAttendees(eventID: eventID)
                }
            }
        }
    }
}

#Preview {
    let fakeEvent = Event(
        recruiterID: "123",
        name: "Test Event",
        location: "Room 101",
        startsAt: Date(),
        endsAt: Date()
    )
    
    return NavigationStack {
        EventDetailView(event: fakeEvent)
            .environmentObject(AuthViewModel())
    }
}
