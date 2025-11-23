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
            ZStack {
                brandNavy.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Event Details")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.leading, 4)
                            
                            GhostTextField(placeholder: "Event Name", text: $name)
                            GhostTextField(placeholder: "Location (e.g. Room 101)", text: $location)
                            GhostTextField(placeholder: "Job Position (e.g. Software Engineer)", text: $jobPosition)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Schedule")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.leading, 4)
                            
                            GhostDatePicker(title: "Starts At", selection: $startsAt)
                            GhostDatePicker(title: "Ends At", selection: $endsAt)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(brandNavy, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
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
                    }) {
                        Text("Create")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(brandGradient)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

struct GhostTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.5)))
            .padding()
            .foregroundStyle(.white)
            .background(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(12)
    }
}

struct GhostDatePicker: View {
    let title: String
    @Binding var selection: Date
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.white)
                .fontWeight(.medium)
            
            Spacer()
            
            DatePicker("", selection: $selection)
                .labelsHidden()
                .colorScheme(.dark)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

#Preview {
    CreateEventView()
        .environmentObject(AuthViewModel())
}
