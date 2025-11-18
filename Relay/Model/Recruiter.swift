//
//  Recruiter.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import Foundation
import FirebaseFirestore

struct Recruiter: Identifiable, Equatable, Codable {
    
    @DocumentID var id: String?
    var name: String
    var email: String
    var companyID: String
    var companyName: String

    // init from firestore data
    init(id: String, dictionary: [String: Any]) {
        self.id = id
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.companyID = dictionary["companyID"] as? String ?? ""
        self.companyName = dictionary["companyName"] as? String ?? ""
    }
    
    init(id: String, name: String, email: String, companyID: String, companyName: String) {
        self.id = id
        self.name = name
        self.email = email
        self.companyID = companyID
        self.companyName = companyName
    }
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "email": email,
            "companyID": companyID,
            "companyName": companyName
        ]
    }
}
