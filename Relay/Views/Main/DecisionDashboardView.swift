//
//  DecisionDashboardView.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//

import SwiftUI

fileprivate let brandNavy = Color(red: 27/255, green: 30/255, blue: 89/255)
fileprivate let brandCyan = Color(red: 0.2, green: 0.8, blue: 0.8)

struct DecisionDashboardView: View {
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
                    } else if authViewModel.allRecruiterDecisions.isEmpty {
                        Text("No 'Interested' Candidates Yet")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 50)
                    } else {
                        ForEach(authViewModel.allRecruiterDecisions) { decision in
                            
                            let candidate = authViewModel.allInterestedCandidates.first { $0.id == decision.candidateID }
                            let event = authViewModel.recruiterEvents.first { $0.id == decision.eventID }
                            
                            NavigationLink(destination: CandidateNoteView(decision: decision)) {
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
        }
        .navigationTitle("Interested Candidates")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(brandNavy, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(candidate?.name ?? "Unknown Candidate")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text(event?.jobPosition ?? "No Position")
                    .font(.subheadline)
                    .foregroundStyle(brandCyan)
                    .fontWeight(.medium)
                
                Text(event?.name ?? "Unknown Event")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.3))
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
    
    var previewCandidate = Candidate(id: "c1", name: "Test Candidate")
    previewCandidate.school = "University of Testing"
    previewCandidate.avatarName = "avatar_1"
    
    var previewEvent = Event(recruiterID: "r1", name: "Fall Tech Fair", location: "Gym", startsAt: Date(), endsAt: Date(), jobPosition: "Software Engineer")
    previewEvent.id = "e1"
    
    var previewDecision = Decision(eventID: "e1", candidateID: "c1", recruiterID: "r1", decision: .interested)
    previewDecision.id = "d1"
    
    vm.allInterestedCandidates = [previewCandidate]
    vm.recruiterEvents = [previewEvent]
    vm.allRecruiterDecisions = [previewDecision]
    
    return NavigationStack {
        DecisionDashboardView()
            .environmentObject(vm)
    }
}
