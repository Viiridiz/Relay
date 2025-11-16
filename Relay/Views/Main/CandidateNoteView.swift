//
//  CandidateNoteView.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//

import SwiftUI

struct CandidateNoteView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    let decision: Decision
    
    @State private var note: String = ""
    @State private var showSendOfferView = false // for modal
    
    // get candidate from decision
    private var candidate: Candidate? {
        authViewModel.allInterestedCandidates.first { $0.id == decision.candidateID }
    }
    
    // get event from decision
    private var event: Event? {
        authViewModel.recruiterEvents.first { $0.id == decision.eventID }
    }
    
    var body: some View {
        // unwrap the candidate
        if let candidate = candidate {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    CandidateProfileDetailView(candidate: candidate)
                }
                
                // note editor
                VStack(alignment: .leading) {
                    Text("Recruiter Notes (Private)")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextEditor(text: $note)
                        .frame(height: 150)
                        .padding(4)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.vertical)
                .background(.bar)
            }
            .navigationTitle(candidate.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // new offer button
                    Button("Send Offer") {
                        showSendOfferView = true
                    }
                    .disabled(authViewModel.isLoading)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save Note") {
                        saveNote()
                    }
                    .disabled(authViewModel.isLoading)
                }
            }
            .onAppear {
                self.note = decision.note ?? ""
            }
            .sheet(isPresented: $showSendOfferView) {
                // present the new sheet
                SendOfferView(
                    candidateID: decision.candidateID,
                    jobPosition: event?.jobPosition ?? "NA"
                )
            }
            
        } else {
            Text("Loading Candidate...")
        }
    }
    
    func saveNote() {
        guard let decisionID = decision.id else {
            print("DEBUG: no decision id found, cant save")
            return
        }
        
        Task {
            await authViewModel.updateDecisionNote(decisionID: decisionID, note: note)
        }
    }
}

#Preview {
    let vm = AuthViewModel()
    
    // 1. candidate
    var candidate = Candidate(id: "c1", name: "John Appleseed")
    candidate.school = "Preview University"
    candidate.avatarName = "avatar_1"
    candidate.prompts = [Prompt(question: "My proudest project is...", answer: "This app.")]
    
    // 2. event
    var event = Event(recruiterID: "r1", name: "Preview Event", location: "Room 101", startsAt: Date(), endsAt: Date(), jobPosition: "iOS Developer")
    event.id = "e1"
    
    // 3. decision
    var decision = Decision(
        eventID: "e1", // matches event
        candidateID: "c1", // matches candidate
        recruiterID: "r1",
        decision: .interested
    )
    decision.id = "d1"
    decision.note = "Looks promising, good project."
    
    vm.allInterestedCandidates = [candidate]
    vm.recruiterEvents = [event]
    vm.allRecruiterDecisions = [decision]
    
    return NavigationStack {
        CandidateNoteView(decision: decision)
            .environmentObject(vm)
    }
}
