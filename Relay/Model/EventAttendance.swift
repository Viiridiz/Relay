//
//  EventAttendance.swift
//  Relay
//
//  Created by user286649 on 11/8/25.
//
import Foundation
import FirebaseFirestore

struct EventAttendance: Identifiable {
    @DocumentID var id: String?
    let eventID: String
    let candidateID: String
    let checkedInAt: Date
    
    // init for a new one
    init(eventID: String, candidateID: String) {
        self.eventID = eventID
        self.candidateID = candidateID
        self.checkedInAt = Date()
    }
    
    // init from firestore
    init?(dictionary: [String: Any]) {
        guard let eventID = dictionary["eventID"] as? String,
              let candidateID = dictionary["candidateID"] as? String,
              let checkedInTimestamp = dictionary["checkedInAt"] as? Timestamp
        else { return nil }
        
        self.eventID = eventID
        self.candidateID = candidateID
        self.checkedInAt = checkedInTimestamp.dateValue()
    }
    
    // convert to dict
    var dictionary: [String: Any] {
        return [
            "eventID": eventID,
            "candidateID": candidateID,
            "checkedInAt": Timestamp(date: checkedInAt)
        ]
    }
}
