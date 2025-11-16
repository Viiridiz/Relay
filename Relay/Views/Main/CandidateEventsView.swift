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
        VStack {
            if authViewModel.isLoading {
                ProgressView()
            } else if authViewModel.candidateEvents.isEmpty {
                Text("You haven't joined any events yet.")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else {
                List(authViewModel.candidateEvents) { event in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(event.name)
                            .font(.headline)
                        Text(event.jobPosition)
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                        Text(event.location)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("My Events")
    }
}

#Preview {
    let vm = AuthViewModel()
    vm.candidateEvents = [
        Event(recruiterID: "1", name: "Tech Fair", location: "Room 101", startsAt: Date(), endsAt: Date(), jobPosition: "Software Engineer")
    ]
    return NavigationStack {
        CandidateEventsView()
            .environmentObject(vm)
    }
}
