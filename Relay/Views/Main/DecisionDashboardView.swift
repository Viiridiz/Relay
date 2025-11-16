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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if authViewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 50)
                } else if authViewModel.allRecruiterDecisions.isEmpty {
                    Text("No 'Interested' Candidates Yet")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 50)
                } else {
                    // iterate decisions
                    ForEach(authViewModel.allRecruiterDecisions) { decision in
                        
                        // find the matching data
                        let candidate = authViewModel.allInterestedCandidates.first { $0.id == decision.candidateID }
                        let event = authViewModel.recruiterEvents.first { $0.id == decision.eventID }
                        
                        // navigate with the decision
                        NavigationLink(value: decision) {
                            InterestedCandidatePill(
                                candidate: candidate,
                                event: event
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Interested Candidates")
        .navigationDestination(for: Decision.self) { decision in
            CandidateNoteView(decision: decision)
        }
    }
}

struct InterestedCandidatePill: View {
    let candidate: Candidate?
    let event: Event?
    
    var body: some View {
        HStack(spacing: 16) {
            Image(candidate?.avatarName ?? "avatar_1")
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .background(Circle().fill(Color(.systemGray5)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(candidate?.name ?? "Unknown Candidate")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(event?.jobPosition ?? "No Position")
                    .font(.subheadline)
                    .foregroundStyle(.primary) // fixed blue
                
                Text(event?.name ?? "Unknown Event")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
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
