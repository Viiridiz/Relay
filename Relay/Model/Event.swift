//
//  Event.swift
//  Relay
//
//  Created by user286649 on 11/8/25.
//
import Foundation
import FirebaseFirestore

struct Event: Identifiable, Hashable {
    @DocumentID var id: String?
    let recruiterID: String
    let name: String
    let location: String
    let startsAt: Date
    let endsAt: Date
    var eventCode: String? // the 6-digit code
    
    // init for a new one
    init(recruiterID: String, name: String, location: String, startsAt: Date, endsAt: Date) {
        self.recruiterID = recruiterID
        self.name = name
        self.location = location
        self.startsAt = startsAt
        self.endsAt = endsAt
    }
    
    // init from firestore
    init?(dictionary: [String: Any]) {
        guard let recruiterID = dictionary["recruiterID"] as? String,
              let name = dictionary["name"] as? String,
              let location = dictionary["location"] as? String,
              let startsAtTimestamp = dictionary["startsAt"] as? Timestamp,
              let endsAtTimestamp = dictionary["endsAt"] as? Timestamp
        else { return nil }
        
        self.recruiterID = recruiterID
        self.name = name
        self.location = location
        self.startsAt = startsAtTimestamp.dateValue()
        self.endsAt = endsAtTimestamp.dateValue()
        self.eventCode = dictionary["eventCode"] as? String
    }
    
    // convert to firestore dict
    var dictionary: [String: Any] {
        return [
            "recruiterID": recruiterID,
            "name": name,
            "location": location,
            "startsAt": Timestamp(date: startsAt),
            "endsAt": Timestamp(date: endsAt),
            "eventCode": eventCode ?? ""
        ]
    }
}
