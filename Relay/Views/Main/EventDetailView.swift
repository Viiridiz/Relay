//
//  EventDetailView.swift
//  Relay
//
//  Created by user286649 on 11/8/25.
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

struct EventDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let event: Event
    
    private var unreviewedCandidates: [Candidate] {
        let decidedCandidateIDs = Set(authViewModel.eventDecisions.map { $0.candidateID })
        return authViewModel.currentEventAttendees.filter { candidate in
            !decidedCandidateIDs.contains(candidate.id ?? "")
        }
    }
    
    var body: some View {
        ZStack {
            brandNavy.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(event.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text(event.location)
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        
                        VStack(spacing: 8) {
                            Text("EVENT CODE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(brandCyan)
                                .tracking(2)
                            
                            Text(event.eventCode ?? "---")
                                .font(.system(size: 48, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .cornerRadius(16)

                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                        
                        VStack(spacing: 16) {
                            let count = unreviewedCandidates.count
                            
                            HStack {
                                Image(systemName: count > 0 ? "person.2.fill" : "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(count > 0 ? .white : brandCyan)
                                
                                Text(count > 0 ? "\(count) candidate(s) waiting" : "All candidates reviewed")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 8)
                            
                            NavigationLink(
                                destination: CandidateReviewView(
                                    candidateQueue: unreviewedCandidates,
                                    eventID: event.id ?? ""
                                )
                            ) {
                                Text(count > 0 ? "Start Review" : "Review Again")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(count > 0 ? AnyShapeStyle(brandGradient) : AnyShapeStyle(Color.white.opacity(0.2)))
                                    .clipShape(Capsule())
                            }
                            .disabled(authViewModel.currentEventAttendees.isEmpty && count == 0)
                            .opacity(authViewModel.currentEventAttendees.isEmpty ? 0.6 : 1)
                        }
                    }
                    .padding()
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(brandNavy, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            if let eventID = event.id {
                Task {
                    await authViewModel.fetchEventAttendees(eventID: eventID)
                }
            }
        }
    }
}
