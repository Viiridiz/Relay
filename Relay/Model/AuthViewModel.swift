//
//  AuthViewModel.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {

    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserAccount?
    
    @Published var candidateProfile: Candidate?
    
    @Published var recruiterProfile: Recruiter?
    @Published var recruiterEvents: [Event] = []
    @Published var currentEventAttendees: [Candidate] = []
    
    @Published var isLoading = false
    @Published var errorMessage = ""

    private var db = Firestore.firestore()

    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchCurrentUser()
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = authResult.user
            await fetchCurrentUser()
        } catch {
            self.errorMessage = error.localizedDescription
            print("DEBUG: Failed to sign in: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func signUp(email: String, password: String, name: String, role: UserAccount.UserRole) async {
        isLoading = true
        errorMessage = ""
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            self.userSession = authResult.user

            let newUser = UserAccount(id: uid, email: email, name: name, userRole: role)
            let userData = newUser.dictionary
            let userAccountRef = db.collection("users").document(uid)
            
            let batch = db.batch()
            batch.setData(userData, forDocument: userAccountRef)

            if role == .candidate {
                let newCandidate = Candidate(id: uid, name: name)
                let candidateRef = db.collection("candidates").document(uid)
                batch.setData(newCandidate.dictionary, forDocument: candidateRef)
                
                self.candidateProfile = newCandidate
                
            } else if role == .recruiter {
                let newRecruiter = Recruiter(id: uid, name: name, email: email, companyID: "NEEDS_COMPANY_ID")
                let recruiterRef = db.collection("recruiters").document(uid)
                batch.setData(newRecruiter.dictionary, forDocument: recruiterRef)
                
                self.recruiterProfile = newRecruiter
            }
            
            try await batch.commit()
            
            self.currentUser = newUser
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("DEBUG: Failed to sign up: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            self.candidateProfile = nil
            self.recruiterProfile = nil
            self.recruiterEvents = []
            self.currentEventAttendees = []
        } catch {
            print("DEBUG: Failed to sign out: \(error.localizedDescription)")
        }
    }

    func fetchCurrentUser() async {
        guard let uid = userSession?.uid else { return }
        
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            guard let data = snapshot.data() else { return }
            
            let user = UserAccount(id: snapshot.documentID, dictionary: data)
            self.currentUser = user
            
            if user?.userRole == .candidate {
                await fetchCandidateProfile(uid: uid)
            } else if user?.userRole == .recruiter {
                await fetchRecruiterProfile(uid: uid)
                await fetchRecruiterEvents(recruiterID: uid)
            }
            
        } catch {
            print("DEBUG: Failed to fetch user: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Candidate Functions
    
    func fetchCandidateProfile(uid: String) async {
        do {
            let snapshot = try await db.collection("candidates").document(uid).getDocument()
            guard let data = snapshot.data() else { return }
            self.candidateProfile = Candidate(id: snapshot.documentID, dictionary: data)
        } catch {
            print("DEBUG: Failed to fetch candidate profile: \(error.localizedDescription)")
        }
    }
    
    func updateCandidateProfile(_ profile: Candidate) async {
        let uid = profile.id
        isLoading = true
        do {
            let data = profile.dictionary
            try await db.collection("candidates").document(uid).setData(data, merge: true)
            self.candidateProfile = profile
        } catch {
            self.errorMessage = error.localizedDescription
            print("DEBUG: Failed to update profile: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    // MARK: - Recruiter Functions
    
    func fetchRecruiterProfile(uid: String) async {
        do {
            let snapshot = try await db.collection("recruiters").document(uid).getDocument()
            guard let data = snapshot.data() else { return }
            self.recruiterProfile = Recruiter(id: snapshot.documentID, dictionary: data)
        } catch {
            print("DEBUG: Failed to fetch recruiter profile: \(error.localizedDescription)")
        }
    }
    
    func fetchRecruiterEvents(recruiterID: String) async {
        self.isLoading = true
        self.recruiterEvents = []
        do {
            let snapshot = try await db.collection("events")
                                      .whereField("recruiterID", isEqualTo: recruiterID)
                                      .getDocuments()
            
            self.recruiterEvents = snapshot.documents.compactMap { doc in
                var event = Event(dictionary: doc.data())
                event?.id = doc.documentID
                return event
            }
        } catch {
            print("DEBUG: Failed to fetch events: \(error.localizedDescription)")
        }
        self.isLoading = false
    }
    
    func createEvent(name: String, location: String, startsAt: Date, endsAt: Date) async {
        guard let uid = currentUser?.id else { return }
        isLoading = true
        do {
            var newEvent = Event(
                recruiterID: uid,
                name: name,
                location: location,
                startsAt: startsAt,
                endsAt: endsAt
            )
            
            let eventCode = generateEventCode()
            newEvent.eventCode = eventCode
            
            let data = newEvent.dictionary
            let docRef = try await db.collection("events").addDocument(data: data)
            
            newEvent.id = docRef.documentID
            self.recruiterEvents.append(newEvent)
        } catch {
            self.errorMessage = error.localizedDescription
            print("DEBUG: Failed to create event: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    private func generateEventCode() -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ123456789"
        return String((0..<6).map{ _ in letters.randomElement()! })
    }
    
    func joinEvent(eventCode: String) async -> Event? {
            guard let uid = currentUser?.id else { return nil }
            self.isLoading = true
            self.errorMessage = ""
            
            do {
                let snapshot = try await db.collection("events")
                                          .whereField("eventCode", isEqualTo: eventCode)
                                          .getDocuments()
                
                guard let eventDoc = snapshot.documents.first,
                      var event = Event(dictionary: eventDoc.data()) else {
                    self.errorMessage = "Invalid event code."
                    self.isLoading = false
                    return nil
                }
                event.id = eventDoc.documentID
                
                let eventID = eventDoc.documentID
                let newAttendance = EventAttendance(eventID: eventID, candidateID: uid)
                let data = newAttendance.dictionary
                
                try await db.collection("eventAttendances").addDocument(data: data)
                
                print("Successfully joined event!")
                self.isLoading = false
                return event
                
            } catch {
                self.errorMessage = "Failed to join event. Try again."
                print("DEBUG: Failed to join event: \(error.localizedDescription)")
                self.isLoading = false
                return nil
            }
        }
    
    func fetchEventAttendees(eventID: String) async {
        self.isLoading = true
        self.currentEventAttendees = []
        do {
            let snapshot = try await db.collection("eventAttendances")
                                      .whereField("eventID", isEqualTo: eventID)
                                      .getDocuments()
            
            let candidateIDs = snapshot.documents.compactMap { doc in
                return doc.data()["candidateID"] as? String
            }
            
            if !candidateIDs.isEmpty {
                let profilesSnapshot = try await db.collection("candidates")
                                                   .whereField(FieldPath.documentID(), in: candidateIDs)
                                                   .getDocuments()
                
                self.currentEventAttendees = profilesSnapshot.documents.compactMap { doc in
                    return Candidate(id: doc.documentID, dictionary: doc.data())
                }
            }
        } catch {
            self.errorMessage = "Failed to fetch attendees: \(error.localizedDescription)"
        }
        self.isLoading = false
    }
}
