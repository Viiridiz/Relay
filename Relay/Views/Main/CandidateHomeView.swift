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

struct PromptCategory: Identifiable {
    let id = UUID()
    let name: String
    let questions: [String]
}

enum SheetContext: Identifiable {
    case selectPrompt
    case editPrompt(Prompt)
    
    var id: String {
        switch self {
        case .selectPrompt: return "select"
        case .editPrompt(let prompt): return prompt.id
        }
    }
}

struct CandidateHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var resumeURL: String = ""
    @State private var coverLetterURL: String = ""
    
    @State private var school: String = ""
    @State private var languages: String = ""
    @State private var certifications: String = ""
    @State private var hobbies: String = ""
    @State private var avatarName: String = "avatar_1"
    
    @State private var prompts: [Prompt] = []
    
    @State private var sheetContext: SheetContext? = nil
    
    let avatars = ["avatar_1", "avatar_2", "avatar_3", "avatar_4", "avatar_5", "avatar_6"]
    
    enum ActiveSection: Hashable {
        case avatar, info, details, docs, prompts
    }
    
    @State private var activeSection: ActiveSection? = nil

    let promptBank: [PromptCategory] = [
        PromptCategory(name: "Projects & Skills", questions: [
            "My proudest project is...",
            "A skill I taught myself is...",
            "The tech stack I find most exciting is...",
            "Something I built that I'm proud of is...",
            "The most complex problem I've solved...",
            "My coding superpower is..."
        ]),
        PromptCategory(name: "Passion & Personality", questions: [
            "I'm passionate about this field because...",
            "I geek out on...",
            "A non-work-related fact about me is...",
            "My ideal team environment is...",
            "If I could only use one app forever...",
            "On weekends you can find me..."
        ]),
        PromptCategory(name: "Career & Goals", questions: [
            "I'm looking for a company that values...",
            "In five years, I want to be...",
            "The best career advice I've received...",
            "A company's mission I admire is...",
            "My dream mentorship looks like...",
            "I want to make an impact by..."
        ]),
        PromptCategory(name: "Work Style", questions: [
            "I work best when...",
            "My approach to debugging is...",
            "When receiving feedback, I...",
            "I prefer communication that is...",
            "To me, a 'finished' product means..."
        ]),
        PromptCategory(name: "The Future", questions: [
            "A technology trend I'm watching is...",
            "I believe the future of tech is...",
            "If I could solve one global issue...",
            "I want to build tools that..."
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
        ZStack {
            brandNavy.ignoresSafeArea()
            
            if authViewModel.candidateProfile != nil {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome, \(name.isEmpty ? "Candidate" : name)!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                
                                Text("Your profile is your first impression.")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(avatarName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                        }
                        .padding(.bottom, 10)
                        
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
                                                Circle().stroke(avatarName == avatar ? Color(red: 0.2, green: 0.8, blue: 0.8) : Color.clear, lineWidth: 3)
                                            )
                                            .onTapGesture {
                                                withAnimation {
                                                    self.avatarName = avatar
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
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
                                CleanTextField(placeholder: "Full Name", text: $name)
                                CleanTextField(placeholder: "Phone (Optional)", text: $phone)
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
                                CleanTextField(placeholder: "School / University", text: $school)
                                CleanTextField(placeholder: "Languages (comma-separated)", text: $languages)
                                CleanTextField(placeholder: "Certifications (comma-separated)", text: $certifications)
                                CleanTextField(placeholder: "Hobbies (comma-separated)", text: $hobbies)
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
                                CleanTextField(placeholder: "Resume URL", text: $resumeURL)
                                    .keyboardType(.URL)
                                CleanTextField(placeholder: "Cover Letter URL (Optional)", text: $coverLetterURL)
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
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
        .navigationTitle("My Profile")
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
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(brandGradient)
                        .clipShape(Capsule())
                }
                .disabled(authViewModel.isLoading)
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

struct CleanTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.5)))
            .padding()
            .foregroundStyle(.white)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .autocapitalization(.none)
    }
}

struct AddPromptButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Text("Add a prompt")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(.white.opacity(0.6))
            )
        }
    }
}

struct PromptCard: View {
    var prompt: Prompt
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(prompt.question)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(red: 0.2, green: 0.8, blue: 0.8))
                    .textCase(.uppercase)
                
                Text(prompt.answer.isEmpty ? "Tap to add..." : prompt.answer)
                    .font(.body)
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

struct PromptQuestionView: View {
    let category: PromptCategory
    var onSelect: (String) -> Void
    
    var body: some View {
        ZStack {
            brandNavy.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(category.questions, id: \.self) { question in
                        Button(action: {
                            onSelect(question)
                        }) {
                            Text(question)
                                .font(.callout)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(brandNavy, for: .navigationBar)
    }
}

struct PromptSelectionView: View {
    let promptBank: [PromptCategory]
    var onSelect: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                brandNavy.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        
                        Text("Select a Prompt")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .padding(.top)

                        VStack(spacing: 12) {
                            ForEach(promptBank) { category in
                                NavigationLink(destination: PromptQuestionView(category: category, onSelect: onSelect)) {
                                    HStack {
                                        Image(systemName: "text.bubble.fill")
                                            .foregroundStyle(Color(red: 0.2, green: 0.8, blue: 0.8))
                                        Text(category.name)
                                            .font(.callout)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white, lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(brandNavy, for: .navigationBar)
        }
    }
}

struct PromptEditorView: View {
    @Binding var prompt: Prompt
    var onSave: () -> Void
    var onDelete: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    let maxChars = 150
    
    init(prompt: Binding<Prompt>, onSave: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self._prompt = prompt
        self.onSave = onSave
        self.onDelete = onDelete
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                brandNavy.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    
                    Text("Edit Prompt")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(prompt.question)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(red: 0.2, green: 0.8, blue: 0.8))
                            .padding(.horizontal)
                        
                        ZStack(alignment: .topLeading) {
                            if prompt.answer.isEmpty {
                                Text("Type your answer here...")
                                    .foregroundStyle(.white.opacity(0.5))
                                    .padding(12)
                            }
                            
                            TextEditor(text: $prompt.answer)
                                .scrollContentBackground(.hidden)
                                .foregroundStyle(.white)
                                .frame(height: 200)
                                .padding(4)
                        }
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .onChange(of: prompt.answer) {
                            if prompt.answer.count > maxChars {
                                prompt.answer = String(prompt.answer.prefix(maxChars))
                            }
                        }
                        
                        Text("\(prompt.answer.count) / \(maxChars)")
                            .font(.caption)
                            .foregroundStyle(prompt.answer.count >= maxChars ? Color(red: 0.85, green: 0.3, blue: 0.6) : .white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    Button(role: .destructive, action: {
                        onDelete()
                    }) {
                        Text("Delete Prompt")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { onSave() }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(brandGradient)
                            .clipShape(Capsule())
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(brandNavy, for: .navigationBar)
        }
    }
}

#Preview("CandidateHomeView") {
    NavigationStack {
        CandidateHomeView()
            .environmentObject(AuthViewModel())
    }
}
