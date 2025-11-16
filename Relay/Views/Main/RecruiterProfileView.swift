//
//  RecruiterProfileView.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//

import SwiftUI

struct RecruiterProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var name: String = ""
    @State private var companyName: String = ""
    
    @State private var infoExpanded = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // --- HEADER ---
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome, \(name.isEmpty ? "Recruiter" : name)!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("This info is shared with candidates you send offers to.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // --- COLLAPSIBLE PILL ---
                ProfileSectionPill(
                    title: "My Info",
                    icon: "person.fill",
                    isExpanded: $infoExpanded
                )
                
                if infoExpanded {
                    VStack(spacing: 12) {
                        TextField("My Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Company Name", text: $companyName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveProfile()
                }
                .disabled(authViewModel.isLoading)
                .fontWeight(.semibold)
            }
        }
        .onAppear(perform: loadProfile)
        .onChange(of: authViewModel.recruiterProfile) {
            loadProfile()
        }
    }
    
    func loadProfile() {
        guard let profile = authViewModel.recruiterProfile else { return }
        self.name = profile.name
        self.companyName = profile.companyName
    }
    
    func saveProfile() {
        guard var profile = authViewModel.recruiterProfile else { return }
        
        profile.name = name
        profile.companyName = companyName
        
        Task {
            await authViewModel.updateRecruiterProfile(profile)
        }
    }
}

#Preview {
    let vm = AuthViewModel()
    vm.recruiterProfile = Recruiter(
        id: "r1",
        name: "Jane Doe",
        email: "jane@google.com",
        companyID: "google",
        companyName: "Google"
    )
    
    return NavigationStack {
        RecruiterProfileView()
            .environmentObject(vm)
    }
}
