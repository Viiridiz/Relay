//
//  CandidateReviewView.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//

import SwiftUI

struct CandidateReviewView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var candidateQueue: [Candidate]
    let eventID: String
    
    private var currentCandidate: Candidate? {
        candidateQueue.first
    }
    
    var body: some View {
        VStack {
            if let candidate = currentCandidate {
                // show the profile
                CandidateProfileDetailView(candidate: candidate)
                
                // buttons
                HStack(spacing: 20) {
                    Button {
                        makeDecision(decision: .passed)
                    } label: {
                        Text("Pass")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.gray.opacity(0.2))
                            .foregroundStyle(.primary)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        makeDecision(decision: .interested)
                    } label: {
                        Text("Interested")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
            } else {
                // queue is empty
                Spacer()
                Text("Review Complete")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("You've reviewed all candidates for this event.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                        .padding()
                }
                Spacer()
            }
        }
        .navigationTitle(currentCandidate?.name ?? "Review Complete")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // force 'Done' button
    }
    
    func makeDecision(decision: Decision.DecisionType) {
        guard let candidate = currentCandidate else { return }
        
        // save to firebase
        Task {
            await authViewModel.saveDecision(
                candidateID: candidate.id,
                eventID: eventID,
                decision: decision
            )
        }
        
        // next candidate
        withAnimation {
            _ = candidateQueue.removeFirst()
        }
    }
}
