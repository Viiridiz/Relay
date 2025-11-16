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
    @State private var isNoteExpanded = false // for pill
    
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
            ZStack {
                // main content
                ScrollView {
                    VStack(spacing: 24) {
                        CandidateProfileDetailView(candidate: candidate, isInteractive: true)
                        
                        // --- COLLAPSIBLE NOTE PILL ---
                        ProfileSectionPill(
                            title: "Recruiter Notes (Private)",
                            icon: "note.text",
                            isExpanded: $isNoteExpanded
                        )
                        
                        if isNoteExpanded {
                            VStack(spacing: 12) {
                                TextEditor(text: $note)
                                    .frame(height: 150)
                                    .padding(4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                
                                Button {
                                    saveNote()
                                    withAnimation {
                                        isNoteExpanded = false // close on save
                                    }
                                } label: {
                                    Text("Save Note")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(.systemGray5))
                                        .foregroundStyle(.primary)
                                        .cornerRadius(10)
                                }
                                .disabled(authViewModel.isLoading)
                            }
                            .padding(.top, 8)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding()
                    .padding(.bottom, 90)
                }
                
                // --- PINNED SEND OFFER BUTTON ---
                VStack {
                    Spacer()
                    Button {
                        showSendOfferView = true
                    } label: {
                        Text("Send Offer")
                            .font(.headline.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(15)
                    }
                    .padding()
                    .background(.bar)
                }
                .disabled(authViewModel.isLoading)
                
            }
            .navigationTitle(candidate.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
            }
            .onAppear {
                self.note = decision.note ?? ""
            }
            .sheet(isPresented: $showSendOfferView) {
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
