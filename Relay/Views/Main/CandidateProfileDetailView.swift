//
//  CandidateProfileDetailView.swift
//  Relay
//
//  Created by user286649 on 11/8/25.
//

import SwiftUI

struct CandidateProfileDetailView: View {
    let candidate: Candidate
    var isInteractive: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // --- HEADER ---
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(candidate.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if !candidate.phone.isEmpty {
                            Text(candidate.phone)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(candidate.avatarName)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .background(Circle().fill(Color(.systemGray5)))
                }
                
                // --- DETAILS
                VStack(alignment: .leading, spacing: 14) {
                    if !candidate.school.isEmpty {
                        ProfileDetailRow(
                            icon: "graduationcap.fill",
                            text: candidate.school
                        )
                    }
                    if !candidate.languages.isEmpty {
                        ProfileDetailRow(
                            icon: "bubble.left.and.bubble.right.fill",
                            text: candidate.languages.joined(separator: ", ")
                        )
                    }
                    if !candidate.hobbies.isEmpty {
                        ProfileDetailRow(
                            icon: "sparkles",
                            text: candidate.hobbies.joined(separator: ", ")
                        )
                    }
                }
                
                // --- DOCUMENT
                VStack(alignment: .leading, spacing: 12) {
                    if !candidate.resumeURL.isEmpty {
                        DocumentButton(
                            title: "View Resume",
                            url: candidate.resumeURL,
                            isInteractive: isInteractive
                        )
                    }
                    if !candidate.coverLetterURL.isEmpty {
                        DocumentButton(
                            title: "View Cover Letter",
                            url: candidate.coverLetterURL,
                            isInteractive: isInteractive
                        )
                    }
                }

                // --- PROMPT
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(candidate.prompts) { prompt in
                        PromptDisplayCard(prompt: prompt)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Candidate Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// --- NEW HELPER VIEWS ---

struct ProfileDetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.callout)
                .frame(width: 20)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.callout)
                .fontWeight(.medium)
        }
    }
}

struct DocumentButton: View {
    let title: String
    let url: String
    let isInteractive: Bool
    
    @ViewBuilder
    private var buttonBody: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.callout)
            Text(title)
                .font(.callout)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isInteractive ? Color(.systemGray5) : Color(.systemGray6))
        .foregroundStyle(isInteractive ? .primary : .secondary)
        .cornerRadius(10)
    }
    
    var body: some View {
        if isInteractive, let url = URL(string: url) {
            Link(destination: url) {
                buttonBody
            }
        } else {
            buttonBody
        }
    }
}

struct PromptDisplayCard: View {
    let prompt: Prompt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(prompt.question)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Text(prompt.answer)
                .font(.title3) // Big answer
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}


// --- PREVIEW ---

#Preview {
    let fakeCandidate: Candidate = {
        var candidate = Candidate(
            id: "123",
            name: "John Appleseed"
        )
        candidate.phone = "555-123-4567"
        candidate.avatarName = "avatar_1"
        candidate.school = "University of Design"
        candidate.languages = ["English", "French"]
        candidate.hobbies = ["Hiking", "iOS Dev"]
        candidate.resumeURL = "https://google.com"
        candidate.prompts = [
            Prompt(question: "In five years, I want to be...", answer: "The owner of my own company"),
            Prompt(question: "A non-work-related fact about me is...", answer: "I am lethal on the dance floor, capable of intricate moves.")
        ]
        return candidate
    }()
    
    NavigationStack {
        
        CandidateProfileDetailView(candidate: fakeCandidate, isInteractive: true)
    }
}
