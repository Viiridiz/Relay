//
//  Decision.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//

import Foundation
import FirebaseFirestore

struct Decision: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let eventID: String
    let candidateID: String
    let recruiterID: String
    let decision: DecisionType
    var note: String?

    enum DecisionType: String, Codable {
        case interested
        case passed
    }
    
    // helper for firestore
    var dictionary: [String: Any] {
        return [
            "eventID": eventID,
            "candidateID": candidateID,
            "recruiterID": recruiterID,
            "decision": decision.rawValue,
            "note": note ?? "" // save note
        ]
    }
}
