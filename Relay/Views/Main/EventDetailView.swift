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
    
    // filters the attendee list against the decisions list
    private var unreviewedCandidates: [Candidate] {
        let decidedCandidateIDs = Set(authViewModel.eventDecisions.map { $0.candidateID })
        
        return authViewModel.currentEventAttendees.filter { candidate in
            !decidedCandidateIDs.contains(candidate.id ?? "")
        }
    }
    
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
            
            VStack {
                let count = unreviewedCandidates.count
                if count > 0 {
                    Text("You have \(count) new candidate(s) to review.")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("All candidates reviewed.")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // OLD STYLE: Direct Destination
                NavigationLink(
                    destination: CandidateReviewView(
                        candidateQueue: unreviewedCandidates,
                        eventID: event.id ?? ""
                    )
                ) {
                    Text(count > 0 ? "Start Review (\(count))" : "Review Again")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(count > 0 ? .blue : .gray)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 4)
                .disabled(authViewModel.currentEventAttendees.isEmpty) 
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
