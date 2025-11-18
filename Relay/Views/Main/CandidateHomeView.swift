import SwiftUI

struct PromptCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let questions: [String]
}

enum SheetContext: Identifiable {
    case selectPrompt
    case editPrompt(Prompt)
    
    var id: String {
        switch self {
        case .selectPrompt:
            return "select"
        case .editPrompt(let prompt):
            return prompt.id
        }
    }
}

// --- MAIN VIEW ---
struct CandidateHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // existing
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var resumeURL: String = ""
    @State private var coverLetterURL: String = ""
    
    // new stuff
    @State private var school: String = ""
    @State private var languages: String = ""
    @State private var certifications: String = ""
    @State private var hobbies: String = ""
    @State private var avatarName: String = "avatar_1"
    
    @State private var prompts: [Prompt] = []
    
    @State private var sheetContext: SheetContext? = nil
    
    let avatars = ["avatar_1", "avatar_2", "avatar_3", "avatar_4", "avatar_5", "avatar_6"]
    
    // enum for sections
    enum ActiveSection: Hashable {
        case avatar, info, details, docs, prompts
    }
    
    // state for collapsible sections
    @State private var activeSection: ActiveSection? = nil

    let promptBank: [PromptCategory] = [
        PromptCategory(name: "Projects & Skills", questions: [
            "My proudest project is...",
            "A skill I taught myself is...",
            "The tech stack I find most exciting is...",
            "Something I built that I'm proud of is...",
            "The most complex problem I've solved..."
        ]),
        PromptCategory(name: "Passion & Personality", questions: [
            "I'm passionate about this field because...",
            "I geek out on...",
            "A non-work-related fact about me is...",
            "My ideal team environment is..."
        ]),
        PromptCategory(name: "Career & Goals", questions: [
            "I'm looking for a company that values...",
            "In five years, I want to be...",
            "The best career advice I've received...",
            "A company's mission I admire is..."
        ])
    ]
    
   
    func sectionBinding(_ section: ActiveSection) -> Binding<Bool> {
        Binding(
            get: { activeSection == section },
            set: { isOpen in
                withAnimation(.spring(duration: 0.3)) {
                    if isOpen {
                        activeSection = section
                    } else {
                        if activeSection == section {
                            activeSection = nil
                        }
                    }
                }
            }
        )
    }
    
    var body: some View {
            if authViewModel.candidateProfile != nil {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // --- HEADER ---
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome, \(name.isEmpty ? "Candidate" : name)!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Your profile is your first impression.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(avatarName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .background(Circle().fill(Color(.systemGray5)))
                        }
                        
                        // --- COLLAPSIBLE PILL SECTIONS ---
                        // We use the shared ProfileSectionPill, passing the custom binding
                        
                        ProfileSectionPill(
                            title: "My Avatar",
                            icon: "face.smiling.fill",
                            isExpanded: sectionBinding(.avatar)
                        )
                        
                        if activeSection == .avatar {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(avatars, id: \.self) { avatar in
                                        Image(avatar)
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle().stroke(avatarName == avatar ? Color.blue : Color.clear, lineWidth: 3)
                                            )
                                            .onTapGesture {
                                                withAnimation {
                                                    self.avatarName = avatar
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        ProfileSectionPill(
                            title: "My Info",
                            icon: "person.fill",
                            isExpanded: sectionBinding(.info)
                        )
                        
                        if activeSection == .info {
                            VStack(spacing: 12) {
                                TextField("Name", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                TextField("Phone (Optional)", text: $phone)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.phonePad)
                            }
                            .padding(.top, 8)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        ProfileSectionPill(
                            title: "My Details",
                            icon: "person.text.rectangle.fill",
                            isExpanded: sectionBinding(.details)
                        )
                        
                        if activeSection == .details {
                            VStack(spacing: 12) {
                                TextField("School / University", text: $school)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                TextField("Languages (comma-separated)", text: $languages)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                TextField("Certifications (comma-separated)", text: $certifications)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                TextField("Hobbies (comma-separated)", text: $hobbies)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                            }
                            .padding(.top, 8)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        ProfileSectionPill(
                            title: "My Documents",
                            icon: "doc.text.fill",
                            isExpanded: sectionBinding(.docs)
                        )
                        
                        if activeSection == .docs {
                            VStack(spacing: 12) {
                                TextField("Resume URL", text: $resumeURL)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .keyboardType(.URL)
                                TextField("Cover Letter URL (Optional)", text: $coverLetterURL)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .keyboardType(.URL)
                            }
                            .padding(.top, 8)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        ProfileSectionPill(
                            title: "My Prompts",
                            icon: "text.bubble.fill",
                            isExpanded: sectionBinding(.prompts)
                        )
                        
                        if activeSection == .prompts {
                            VStack(spacing: 12) {
                                ForEach(prompts) { prompt in
                                    PromptCard(prompt: prompt) {
                                        self.sheetContext = .editPrompt(prompt)
                                    }
                                }
                                
                                if prompts.count < 3 {
                                    AddPromptButton {
                                        self.sheetContext = .selectPrompt
                                    }
                                }
                            }
                            .padding(.top, 8)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        Spacer()
                        
                    }
                    .padding()
                }
                .navigationTitle("My Profile")
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
                .onAppear(perform: loadProfileData)
                .onChange(of: authViewModel.candidateProfile) {
                    loadProfileData()
                }
                .sheet(item: $sheetContext) { context in
                    switch context {
                        
                    case .selectPrompt:
                        PromptSelectionView(promptBank: promptBank, onSelect: { question in
                            let newPrompt = Prompt(question: question, answer: "")
                            self.prompts.append(newPrompt)
                            self.sheetContext = .editPrompt(newPrompt)
                        })
                        
                    case .editPrompt(let prompt):
                        if let index = self.prompts.firstIndex(where: { $0.id == prompt.id }) {
                            PromptEditorView(
                                prompt: $prompts[index],
                                onSave: {
                                    self.sheetContext = nil
                                },
                                onDelete: {
                                    self.prompts.remove(at: index)
                                    self.sheetContext = nil
                                }
                            )
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
    
    func loadProfileData() {
        guard let profile = authViewModel.candidateProfile else { return }
        self.name = profile.name
        self.phone = profile.phone
        self.resumeURL = profile.resumeURL
        self.coverLetterURL = profile.coverLetterURL
        self.prompts = profile.prompts
        
        self.school = profile.school
        self.avatarName = profile.avatarName
        self.languages = profile.languages.joined(separator: ", ")
        self.certifications = profile.certifications.joined(separator: ", ")
        self.hobbies = profile.hobbies.joined(separator: ", ")
    }
    
    private func splitString(_ text: String) -> [String] {
        return text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    func saveProfile() {
        if var profile = authViewModel.candidateProfile {
            profile.name = name
            profile.phone = phone
            profile.resumeURL = resumeURL
            profile.coverLetterURL = coverLetterURL
            profile.prompts = prompts
            
            profile.school = school
            profile.avatarName = avatarName
            profile.languages = splitString(languages)
            profile.certifications = splitString(certifications)
            profile.hobbies = splitString(hobbies)
            
            Task {
                await authViewModel.updateCandidateProfile(profile)
            }
        }
    }
}

//
// --- ALL HELPER VIEWS AND PREVIEWS BELOW ---


struct AddPromptButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Text("Add a prompt")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "plus")
                    .foregroundStyle(.primary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct PromptCard: View {
    var prompt: Prompt
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(prompt.question)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text(prompt.answer.isEmpty ? "Tap to add..." : prompt.answer)
                    .font(.callout)
                    .foregroundStyle(prompt.answer.isEmpty ? .secondary : .primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

struct PromptQuestionView: View {
    let category: PromptCategory
    var onSelect: (String) -> Void
    
    var body: some View {
        List(category.questions, id: \.self) { question in
            Button(action: {
                onSelect(question)
            }) {
                Text(question)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .listStyle(.inset)
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PromptSelectionView: View {
    let promptBank: [PromptCategory]
    var onSelect: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 20) {
                
                Text("Select a Prompt")
                    .font(.title2.bold())
                    .padding(.top)

                List(promptBank) { category in
                    NavigationLink(value: category) {
                        HStack {
                            Image(systemName: "text.bubble.fill")
                                .foregroundStyle(.primary)
                            Text(category.name)
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationDestination(for: PromptCategory.self) { category in
                PromptQuestionView(category: category, onSelect: onSelect)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct PromptEditorView: View {
    @Binding var prompt: Prompt
    var onSave: () -> Void
    var onDelete: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    let maxChars = 150
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                Text("Edit Prompt")
                    .font(.title2.bold())
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(prompt.question)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    TextEditor(text: $prompt.answer)
                        .frame(height: 200)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .onChange(of: prompt.answer) {
                            if prompt.answer.count > maxChars {
                                prompt.answer = String(prompt.answer.prefix(maxChars))
                            }
                        }
                    
                    Text("\(prompt.answer.count) / \(maxChars)")
                        .font(.caption)
                        .foregroundStyle(prompt.answer.count >= maxChars ? .red : .secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button("Delete Prompt", role: .destructive) {
                    onDelete()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { onSave() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}


// --- PREVIEWS ---

#Preview("CandidateHomeView") {
    NavigationStack {
        CandidateHomeView()
            .environmentObject(AuthViewModel())
    }
}

#Preview("PromptSelectionView") {
    let previewBank: [PromptCategory] = [
        PromptCategory(name: "Projects & Skills", questions: ["q1", "q2"]),
        PromptCategory(name:"Passion & Personality", questions: ["q3", "q4"]),
    ]
    return PromptSelectionView(
        promptBank: previewBank,
        onSelect: { _ in }
    )
}

#Preview("PromptEditorView") {
    PromptEditorView(
        prompt: .constant(Prompt(question: "My proudest project is...", answer: "I built this app!")),
        onSave: { },
        onDelete: { }
    )
}
