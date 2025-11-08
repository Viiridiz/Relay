//
//  CandidateProfileDetailView.swift
//  Relay
//
//  Created by user286649 on 11/8/25.
//

import SwiftUI

struct CandidateProfileDetailView: View {
    let candidate: Candidate
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(candidate.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if !candidate.phone.isEmpty {
                    Text(candidate.phone)
                        .font(.headline)
                }
                
                VStack(alignment: .leading) {
                    Text("Documents")
                        .font(.headline)
                    Text("Resume: \(candidate.resumeURL)")
                    Text("Cover Letter: \(candidate.coverLetterURL)")
                }
                
                VStack(alignment: .leading) {
                    Text("Prompts")
                        .font(.headline)
                    
                    ForEach(candidate.prompts, id: \.self) { prompt in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(prompt.question)
                                .font(.callout)
                                .fontWeight(.semibold)
                            Text(prompt.answer)
                                .font(.callout)
                                .foregroundStyle(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Candidate Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let fakeCandidate = Candidate(id: "123", name: "John Appleseed")
    
    return NavigationStack {
        CandidateProfileDetailView(candidate: fakeCandidate)
    }
}
