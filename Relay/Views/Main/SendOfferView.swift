//
//  SendOfferView.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//

import SwiftUI

struct SendOfferView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    let candidateID: String
    @State var jobPosition: String
    @State var message: String = "We were very impressed with your profile and would like to move forward with the interview process."
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Offer Details")) {
                    TextField("Job Position", text: $jobPosition)
                    
                    VStack(alignment: .leading) {
                        Text("Message")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextEditor(text: $message)
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Send Offer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Send") {
                        Task {
                            await authViewModel.sendOffer(
                                candidateID: candidateID,
                                jobPosition: jobPosition,
                                message: message
                            )
                            dismiss()
                        }
                    }
                    .disabled(jobPosition.isEmpty || message.isEmpty)
                }
            }
        }
    }
}
