//
//  CandidateEventsView.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//

import SwiftUI

struct CandidateEventsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if authViewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 50)
                } else if authViewModel.candidateEvents.isEmpty {
                    Text("You haven't joined any events yet.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
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
        .navigationTitle("My Events")
    }
}


struct EventPillView: View {
    let event: Event
    
    // helper to format date
    private var eventDate: String {
        event.startsAt.formatted(date: .abbreviated, time: .omitted)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // icon
            Image(systemName: "calendar")
                .font(.title3)
                .foregroundStyle(.primary)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(event.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(event.jobPosition)
                    .font(.subheadline)
                    .foregroundStyle(.primary) // fixed blue
                
                Text("\(event.location) · \(eventDate)")
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
        startsAt: Date().addingTimeInterval(86400 * 30), // 30 days from now
        endsAt: Date(),
        jobPosition: "Data Analyst Intern"
    )
    
    vm.candidateEvents = [event1, event2]
    
    return NavigationStack {
        CandidateEventsView()
            .environmentObject(vm)
    }
}
