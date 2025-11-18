//
//  RecruiterEventsView.swift
//  Relay
//
//  Created by user286649 on 11/8/25.
//
import SwiftUI

struct RecruiterEventsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingCreateSheet = false
    
    var body: some View {
        VStack {
            List(authViewModel.recruiterEvents) { event in
                NavigationLink(destination: EventDetailView(event: event)) {
                    VStack(alignment: .leading) {
                        Text(event.name)
                            .font(.headline)
                        Text(event.location)
                            .font(.subheadline)
                        Text(event.eventCode ?? "No Code")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .bold()
                    }
                }
            }
        }
        .navigationTitle("Your Events")
        .toolbar {
            Button(action: {
                showingCreateSheet = true
            }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateEventView()
        }
    }
}

#Preview {
    NavigationStack {
        RecruiterEventsView()
            .environmentObject(AuthViewModel())
    }
}
