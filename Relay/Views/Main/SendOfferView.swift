//
//  SendOfferView.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//
import SwiftUI

fileprivate let brandNavy = Color(red: 27/255, green: 30/255, blue: 89/255)
fileprivate let brandGradient = LinearGradient(
    colors: [
        Color(red: 0.85, green: 0.3, blue: 0.6),
        Color(red: 0.4, green: 0.3, blue: 0.8),
        Color(red: 0.2, green: 0.8, blue: 0.8)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

struct SendOfferView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    let candidateID: String
    @State var jobPosition: String
    @State var message: String = "We were very impressed with your profile and would like to move forward with the interview process."
    
    init(candidateID: String, jobPosition: String) {
        self.candidateID = candidateID
        _jobPosition = State(initialValue: jobPosition)
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                brandNavy.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        Text("Offer Details")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            GhostTextField(placeholder: "Job Position", text: $jobPosition)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Message")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.leading, 4)
                                
                                ZStack(alignment: .topLeading) {
                                    if message.isEmpty {
                                        Text("Enter your message...")
                                            .foregroundStyle(.white.opacity(0.3))
                                            .padding(12)
                                    }
                                    
                                    TextEditor(text: $message)
                                        .scrollContentBackground(.hidden)
                                        .foregroundStyle(.white)
                                        .frame(height: 200)
                                        .padding(4)
                                }
                                .background(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Send Offer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(brandNavy, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            await authViewModel.sendOffer(
                                candidateID: candidateID,
                                jobPosition: jobPosition,
                                message: message
                            )
                            dismiss()
                        }
                    }) {
                        Text("Send")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(brandGradient)
                            .clipShape(Capsule())
                    }
                    .disabled(jobPosition.isEmpty || message.isEmpty)
                    .opacity(jobPosition.isEmpty || message.isEmpty ? 0.5 : 1)
                }
            }
        }
    }
}
