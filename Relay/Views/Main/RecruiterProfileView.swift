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

struct RecruiterProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var name: String = ""
    @State private var companyName: String = ""
    
    @State private var infoExpanded = true
    
    var body: some View {
        ZStack {
            brandNavy.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome, \(name.isEmpty ? "Recruiter" : name)!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text("This info is shared with candidates you send offers to.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.bottom, 8)
                    
                    ProfileSectionPill(
                        title: "My Info",
                        icon: "person.fill",
                        isExpanded: $infoExpanded
                    )
                    
                    if infoExpanded {
                        VStack(spacing: 12) {
                            GhostTextField(placeholder: "My Name", text: $name)
                            GhostTextField(placeholder: "Company Name", text: $companyName)
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(brandNavy, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    saveProfile()
                }) {
                    Text("Save")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(brandGradient)
                        .clipShape(Capsule())
                }
                .disabled(authViewModel.isLoading)
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
