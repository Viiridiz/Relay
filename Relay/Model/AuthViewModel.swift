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
    @Published var candidateEvents: [Event] = []
    @Published var candidateNotifications: [Notification] = []
    
    @Published var recruiterProfile: Recruiter?
    @Published var recruiterEvents: [Event] = []
    @Published var currentEventAttendees: [Candidate] = []
    
    @Published var eventDecisions: [Decision] = []
    
    @Published var allRecruiterDecisions: [Decision] = []
    @Published var allInterestedCandidates: [Candidate] = []
    
    @Published var isLoading = false
    @Published var errorMessage = ""

    private var db = Firestore.firestore()
    // listener handle
    private var notificationListener: ListenerRegistration?

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
                let newRecruiter = Recruiter(
                    id: uid,
                    name: name,
                    email: email,
                    companyID: "NEEDS_COMPANY_ID",
                    companyName: "NEEDS_COMPANY_NAME"
                )
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
        // stop listening
        notificationListener?.remove()
        notificationListener = nil
        
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            self.candidateProfile = nil
            self.candidateEvents = []
            self.candidateNotifications = []
            self.recruiterProfile = nil
            self.recruiterEvents = []
            self.currentEventAttendees = []
            self.eventDecisions = []
            self.allRecruiterDecisions = []
            self.allInterestedCandidates = []
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
                await fetchCandidateEvents(uid: uid)
                listenForCandidateNotifications(uid: uid) // changed
            } else if user?.userRole == .recruiter {
                await fetchRecruiterProfile(uid: uid)
                await fetchRecruiterEvents(recruiterID: uid)
                await fetchAllInterestedData()
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
    
    func fetchCandidateEvents(uid: String) async {
        self.isLoading = true
        self.candidateEvents = []
        
        do {
            let snapshot = try await db.collection("eventAttendances")
                .whereField("candidateID", isEqualTo: uid)
                .getDocuments()
            
            let eventIDs = snapshot.documents.compactMap { doc in
                return doc.data()["eventID"] as? String
            }
            
            if !eventIDs.isEmpty {
                let eventsSnapshot = try await db.collection("events")
                    .whereField(FieldPath.documentID(), in: eventIDs)
                    .getDocuments()
                
                self.candidateEvents = eventsSnapshot.documents.compactMap { doc in
                    var event = Event(dictionary: doc.data())
                    event?.id = doc.documentID
                    return event
                }
            }
        } catch {
            print("DEBUG: Failed to fetch candidate events: \(error.localizedDescription)")
        }
        
        self.isLoading = false
    }
    
    // changed to real-time listener
    func listenForCandidateNotifications(uid: String) {
        // clear old listener
        notificationListener?.remove()
        
        let query = db.collection("notifications")
            .whereField("candidateID", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
        
        self.notificationListener = query.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("DEBUG: Error fetching notifications: \(error?.localizedDescription ?? "unknown")")
                return
            }
            
            // parse and include doc ID
            self.candidateNotifications = snapshot.documents.compactMap { doc in
                var notification = Notification(dictionary: doc.data())
                notification?.id = doc.documentID // make sure id is set
                return notification
            }
        }
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
    
    func createEvent(name: String, location: String, startsAt: Date, endsAt: Date, jobPosition: String) async {
        guard let uid = currentUser?.id else { return }
        isLoading = true
        do {
            var newEvent = Event(
                recruiterID: uid,
                name: name,
                location: location,
                startsAt: startsAt,
                endsAt: endsAt,
                jobPosition: jobPosition
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
                
                self.candidateEvents.append(event)
                
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
        self.eventDecisions = []
        
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
            
            await fetchEventDecisions(eventID: eventID)
            
        } catch {
            self.errorMessage = "Failed to fetch attendees: \(error.localizedDescription)"
        }
        self.isLoading = false
    }
    
    // MARK: - Decision & Notification Functions
    
    private func parseDecision(doc: QueryDocumentSnapshot) -> Decision {
        let data = doc.data()
        let eventID = data["eventID"] as? String ?? ""
        let candidateID = data["candidateID"] as? String ?? ""
        let recruiterID = data["recruiterID"] as? String ?? ""
        let decisionRaw = data["decision"] as? String ?? ""
        let decision = Decision.DecisionType(rawValue: decisionRaw) ?? .passed
        let note = data["note"] as? String
        
        var newDecision = Decision(
            eventID: eventID,
            candidateID: candidateID,
            recruiterID: recruiterID,
            decision: decision
        )
        newDecision.id = doc.documentID
        newDecision.note = note
        return newDecision
    }
    
    func fetchEventDecisions(eventID: String) async {
        
        guard let recruiterID = self.currentUser?.id else { return }
        
        do {
            let snapshot = try await db.collection("decisions")
                .whereField("eventID", isEqualTo: eventID)
                .whereField("recruiterID", isEqualTo: recruiterID)
                .getDocuments()
            
            self.eventDecisions = snapshot.documents.compactMap { doc in
                return self.parseDecision(doc: doc)
            }
        } catch {
            print("DEBUG: Failed to fetch decisions: \(error.localizedDescription)")
            self.errorMessage = "Failed to fetch decisions: \(error.localizedDescription)"
        }
    }
    
    func saveDecision(candidateID: String, eventID: String, decision: Decision.DecisionType) async {
        guard let recruiterID = self.currentUser?.id else {
            print("DEBUG: No recruiter ID found, can't save decision.")
            return
        }
        
        var newDecision = Decision(
            eventID: eventID,
            candidateID: candidateID,
            recruiterID: recruiterID,
            decision: decision
        )
        
        do {
            let data = newDecision.dictionary
            let docRef = try await db.collection("decisions").addDocument(data: data)
            newDecision.id = docRef.documentID
            
            self.eventDecisions.append(newDecision)
            if newDecision.decision == .interested {
                self.allRecruiterDecisions.append(newDecision)
                if !self.allInterestedCandidates.contains(where: { $0.id == candidateID }) {
                    await fetchCandidateProfileForDashboard(uid: candidateID)
                }
            }
            
        } catch {
            print("DEBUG: Failed to save decision: \(error.localizedDescription)")
            self.errorMessage = "Failed to save decision: \(error.localizedDescription)"
        }
    }
    
    func fetchAllInterestedData() async {
        guard let recruiterID = self.currentUser?.id else { return }
        self.isLoading = true
        self.allRecruiterDecisions = []
        self.allInterestedCandidates = []
        
        do {
            let snapshot = try await db.collection("decisions")
                .whereField("recruiterID", isEqualTo: recruiterID)
                .whereField("decision", isEqualTo: "interested")
                .getDocuments()
            
            self.allRecruiterDecisions = snapshot.documents.compactMap { doc in
                return self.parseDecision(doc: doc)
            }
            
            let candidateIDs = Set(self.allRecruiterDecisions.map { $0.candidateID })
            
            if !candidateIDs.isEmpty {
                let profilesSnapshot = try await db.collection("candidates")
                    .whereField(FieldPath.documentID(), in: Array(candidateIDs))
                    .getDocuments()
                
                self.allInterestedCandidates = profilesSnapshot.documents.compactMap { doc in
                    return Candidate(id: doc.documentID, dictionary: doc.data())
                }
            }
        } catch {
            print("DEBUG: Failed to fetch all interested data: \(error.localizedDescription)")
            self.errorMessage = "Failed to fetch dashboard data."
        }
        self.isLoading = false
    }
    
    private func fetchCandidateProfileForDashboard(uid: String) async {
        do {
            let snapshot = try await db.collection("candidates").document(uid).getDocument()
            guard let data = snapshot.data() else { return }
            let candidate = Candidate(id: (snapshot.documentID), dictionary: data)
            self.allInterestedCandidates.append(candidate)
        } catch {
            print("DEBUG: Failed to fetch single candidate profile: \(error.localizedDescription)")
        }
    }

    func updateDecisionNote(decisionID: String, note: String) async {
        self.isLoading = true
        do {
            try await db.collection("decisions").document(decisionID).setData(
                ["note": note],
                merge: true
            )
            
            if let index = self.allRecruiterDecisions.firstIndex(where: { $0.id == decisionID }) {
                self.allRecruiterDecisions[index].note = note
            }
        } catch {
            print("DEBUG: Failed to update note: \(error.localizedDescription)")
            self.errorMessage = "Failed to save note."
        }
        self.isLoading = false
    }
    
    func sendOffer(candidateID: String, jobPosition: String, message: String) async {
        guard let recruiter = self.recruiterProfile else {
            print("DEBUG: No recruiter profile found.")
            return
        }
        
        self.isLoading = true
        
        let notification = Notification(
            candidateID: candidateID,
            recruiterName: recruiter.name,
            companyName: recruiter.companyName,
            jobPosition: jobPosition,
            message: message
        )
        
        do {
            try await db.collection("notifications").addDocument(data: notification.dictionary)
        } catch {
            print("DEBUG: Failed to send offer: \(error.localizedDescription)")
            self.errorMessage = "Failed to send offer."
        }
        
        self.isLoading = false
    }
    
    func markNotificationAsRead(notificationID: String) async {
        // update remote
        do {
            try await db.collection("notifications").document(notificationID).setData(
                ["isRead": true],
                merge: true
            )
            
            // update local
            if let index = self.candidateNotifications.firstIndex(where: { $0.id == notificationID }) {
                self.candidateNotifications[index].isRead = true
            }
        } catch {
            print("DEBUG: Failed to mark as read: \(error.localizedDescription)")
        }
    }
}
