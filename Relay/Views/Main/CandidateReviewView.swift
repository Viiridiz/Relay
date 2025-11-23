//
//  CandidateReviewView.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
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

struct CandidateReviewView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var candidateQueue: [Candidate]
    let eventID: String
    
    private var currentCandidate: Candidate? {
        candidateQueue.first
    }
    
    var body: some View {
        ZStack {
            brandNavy.ignoresSafeArea()
            
            if let candidate = currentCandidate {
                ScrollView {
                    VStack(spacing: 24) {
                        CandidateProfileDetailView(candidate: candidate, isInteractive: false)
                        
                        Spacer(minLength: 20)
                        
                        HStack(spacing: 20) {
                            Button {
                                makeDecision(decision: .passed)
                            } label: {
                                Text("Pass")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .foregroundStyle(.white)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                makeDecision(decision: .interested)
                            } label: {
                                Text("Interested")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(brandGradient)
                                    .foregroundStyle(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                    .padding()
                }
                
            } else {
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(brandCyan)
                    
                    Text("Review Complete")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Text("You've reviewed all candidates for this event.")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(brandGradient)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
                .padding()
            }
        }
        .navigationTitle(currentCandidate?.name ?? "Review Complete")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(brandNavy, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
    
    func makeDecision(decision: Decision.DecisionType) {
        guard let candidate = currentCandidate, let candidateID = candidate.id else { return }
        
        Task {
            await authViewModel.saveDecision(
                candidateID: candidateID,
                eventID: eventID,
                decision: decision
            )
        }
        
        withAnimation {
            if !candidateQueue.isEmpty {
                _ = candidateQueue.removeFirst()
            }
        }
    }
}
