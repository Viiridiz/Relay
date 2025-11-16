//
//  Recruiter.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import Foundation

struct Recruiter: Identifiable, Equatable {
    
    let id: String
    var name: String
    var email: String
    var companyID: String
    var companyName: String

    // all initializers
    init(id: String, dictionary: [String: Any]) {
        self.id = id
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.companyID = dictionary["companyID"] as? String ?? ""
        self.companyName = dictionary["companyName"] as? String ?? "" // load new
    }
    
    init(id: String, name: String, email: String, companyID: String, companyName: String) {
        self.id = id
        self.name = name
        self.email = email
        self.companyID = companyID
        self.companyName = companyName
    }
    
    // convert model to dictionary for firestore
    var dictionary: [String: Any] {
        return [
            "name": name,
            "email": email,
            "companyID": companyID,
            "companyName": companyName // save new
        ]
    }
}
