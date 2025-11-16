//
//  DecisionDashboardView.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//

import SwiftUI

struct DecisionDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            if authViewModel.isLoading {
                ProgressView()
            } else if authViewModel.allRecruiterDecisions.isEmpty {
                Text("No 'Interested' Candidates Yet")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else {
                // iterate decisions, not candidates
                List(authViewModel.allRecruiterDecisions) { decision in
                    
                    // find the matching data
                    let candidate = authViewModel.allInterestedCandidates.first { $0.id == decision.candidateID }
                    let event = authViewModel.recruiterEvents.first { $0.id == decision.eventID }
                    
                    // navigate with the decision
                    NavigationLink(value: decision) {
                        HStack {
                            Image(candidate?.avatarName ?? "avatar_1")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(candidate?.name ?? "Unknown Candidate")
                                    .font(.headline)
                                Text(event?.name ?? "Unknown Event") // show event name
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                Text(event?.jobPosition ?? "No Position") // show job
                                    .font(.callout)
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Interested Candidates")
        .navigationDestination(for: Decision.self) { decision in
            CandidateNoteView(decision: decision)
        }
    }
}

#Preview {
    let vm = AuthViewModel()
    
    // 1. candidate
    var previewCandidate = Candidate(id: "c1", name: "Test Candidate")
    previewCandidate.school = "University of Testing"
    previewCandidate.avatarName = "avatar_1"
    
    // 2. event
    var previewEvent = Event(recruiterID: "r1", name: "Fall Tech Fair", location: "Gym", startsAt: Date(), endsAt: Date(), jobPosition: "Software Engineer")
    previewEvent.id = "e1"
    
    // 3. decision
    var previewDecision = Decision(eventID: "e1", candidateID: "c1", recruiterID: "r1", decision: .interested)
    previewDecision.id = "d1"
    
    // load into vm
    vm.allInterestedCandidates = [previewCandidate]
    vm.recruiterEvents = [previewEvent]
    vm.allRecruiterDecisions = [previewDecision]
    
    return NavigationStack {
        DecisionDashboardView()
            .environmentObject(vm)
    }
}
