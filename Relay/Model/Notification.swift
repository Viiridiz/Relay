//
//  Notification.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//

import Foundation
import FirebaseFirestore

struct Notification: Identifiable, Codable {
    @DocumentID var id: String?
    let candidateID: String
    let recruiterName: String
    let companyName: String
    let jobPosition: String
    let message: String
    let createdAt: Date
    var isRead: Bool = false
    
    // from firestore
    init?(dictionary: [String: Any]) {
        guard
            let candidateID = dictionary["candidateID"] as? String,
            let recruiterName = dictionary["recruiterName"] as? String,
            let companyName = dictionary["companyName"] as? String,
            let jobPosition = dictionary["jobPosition"] as? String,
            let message = dictionary["message"] as? String,
            let createdAtTimestamp = dictionary["createdAt"] as? Timestamp
        else {
            return nil
        }
        
        self.candidateID = candidateID
        self.recruiterName = recruiterName
        self.companyName = companyName
        self.jobPosition = jobPosition
        self.message = message
        self.createdAt = createdAtTimestamp.dateValue()
        self.isRead = dictionary["isRead"] as? Bool ?? false
    }
    
    // for creating a new one
    init(candidateID: String, recruiterName: String, companyName: String, jobPosition: String, message: String) {
        self.candidateID = candidateID
        self.recruiterName = recruiterName
        self.companyName = companyName
        self.jobPosition = jobPosition
        self.message = message
        self.createdAt = Date()
        self.isRead = false
    }
    
    var dictionary: [String: Any] {
        return [
            "candidateID": candidateID,
            "recruiterName": recruiterName,
            "companyName": companyName,
            "jobPosition": jobPosition,
            "message": message,
            "createdAt": Timestamp(date: createdAt),
            "isRead": isRead
        ]
    }
}
