//
//  CandidateNoteView.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//

import SwiftUI

fileprivate let brandNavy = Color(red: 27/255, green: 30/255, blue: 89/255)
fileprivate let brandCyan = Color(red: 0.2, green: 0.8, blue: 0.8)
fileprivate let brandGradient = LinearGradient(
    colors: [
        Color(red: 0.85, green: 0.3, blue: 0.6),
        Color(red: 0.4, green: 0.3, blue: 0.8),
        Color(red: 0.2, green: 0.8, blue: 0.8)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

struct CandidateNoteView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    let decision: Decision
    
    @State private var note: String = ""
    @State private var showSendOfferView = false
    @State private var isNoteExpanded = false
    
    private var candidate: Candidate? {
        authViewModel.allInterestedCandidates.first { $0.id == decision.candidateID }
    }
    
    private var event: Event? {
        authViewModel.recruiterEvents.first { $0.id == decision.eventID }
    }
    
    init(decision: Decision) {
        self.decision = decision
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            brandNavy.ignoresSafeArea()
            
            if let candidate = candidate {
                VStack(spacing: 0) {
                    // Scrollable Content
                    ScrollView {
                        VStack(spacing: 24) {
                            CandidateProfileDetailView(candidate: candidate, isInteractive: true)
                            
                            ProfileSectionPill(
                                title: "Recruiter Notes (Private)",
                                icon: "note.text",
                                isExpanded: $isNoteExpanded
                            )
                            
                            if isNoteExpanded {
                                VStack(spacing: 12) {
                                    TextEditor(text: $note)
                                        .scrollContentBackground(.hidden)
                                        .foregroundStyle(.white)
                                        .frame(height: 150)
                                        .padding(4)
                                        .background(Color.white.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                        .cornerRadius(12)
                                    
                                    Button {
                                        saveNote()
                                        withAnimation {
                                            isNoteExpanded = false
                                        }
                                    } label: {
                                        Text("Save Note")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white.opacity(0.2))
                                            .foregroundStyle(.white)
                                            .cornerRadius(12)
                                    }
                                    .disabled(authViewModel.isLoading)
                                }
                                .padding(.top, 8)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding()
                        .padding(.bottom, 20) // Padding for scroll content
                    }
                    
                    // Pinned Bottom Bar
                    VStack {
                        Button {
                            showSendOfferView = true
                        } label: {
                            Text("Send Offer")
                                .font(.headline.bold())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(brandGradient)
                                .foregroundStyle(.white)
                                .cornerRadius(30)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding()
                    .background(brandNavy) // Solid background to cover scrolling content
                }
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
        .navigationTitle(candidate?.name ?? "Candidate")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(brandNavy, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            self.note = decision.note ?? ""
        }
        .sheet(isPresented: $showSendOfferView) {
            SendOfferView(
                candidateID: decision.candidateID,
                jobPosition: event?.jobPosition ?? "NA"
            )
        }
    }
    
    func saveNote() {
        guard let decisionID = decision.id else { return }
        Task {
            await authViewModel.updateDecisionNote(decisionID: decisionID, note: note)
        }
    }
}
