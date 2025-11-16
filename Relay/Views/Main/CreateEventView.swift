//
//  CreateEventView.swift
//  Relay
//
//  Created by user286649 on 11/8/25.
//
import SwiftUI

struct CreateEventView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var jobPosition: String = ""
    @State private var startsAt: Date = Date()
    @State private var endsAt: Date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Event Name", text: $name)
                    TextField("Location (e.g., 'Room 101')", text: $location)
                    TextField("Job Position (e.g., 'Software Engineer')", text: $jobPosition)
                }
                
                Section(header: Text("Event Schedule")) {
                    DatePicker("Starts At", selection: $startsAt)
                    DatePicker("Ends At", selection: $endsAt)
                }
            }
            .navigationTitle("New Event")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Create") {
                    // call the viewmodel
                    Task {
                        await authViewModel.createEvent(
                            name: name,
                            location: location,
                            startsAt: startsAt,
                            endsAt: endsAt,
                            jobPosition: jobPosition
                        )
                        dismiss()
                    }
                }
            )
        }
    }
}

#Preview {
    CreateEventView()
        .environmentObject(AuthViewModel())
}
