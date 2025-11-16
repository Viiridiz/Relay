//
//  Candidate.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import Foundation

struct Prompt: Identifiable, Hashable {
    // use question as id
    var id: String { question }
    let question: String
    var answer: String
    
    // init for a new prompt
    init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
    
    // init from firestore data
    init?(dictionary: [String: Any]) {
        guard let question = dictionary["question"] as? String,
              let answer = dictionary["answer"] as? String else { return nil }
        self.question = question
        self.answer = answer
    }
    
    // convert prompt to dictionary for firestore
    var dictionary: [String: Any] {
        return ["question": question, "answer": answer]
    }
}


// this is our main candidate model
struct Candidate: Identifiable, Equatable, Hashable {
    
    let id: String // matches auth uid
    var name: String
    var phone: String
    var resumeURL: String
    var coverLetterURL: String
    var prompts: [Prompt] // array of answered prompts
    
    var school: String
    var languages: [String]
    var certifications: [String]
    var hobbies: [String]
    var avatarName: String
    
    // init for a new candidate
    init(id: String, name: String) {
        self.id = id
        self.name = name
        self.phone = ""
        self.resumeURL = ""
        self.coverLetterURL = ""
        self.prompts = [] // starts empty
        
        // init new stuff
        self.school = ""
        self.languages = []
        self.certifications = []
        self.hobbies = []
        self.avatarName = "avatar_default" // default pic
    }
    
    // init from firestore data
    init(id: String, dictionary: [String: Any]) {
        self.id = id
        self.name = dictionary["name"] as? String ?? ""
        self.phone = dictionary["phone"] as? String ?? ""
        self.resumeURL = dictionary["resumeURL"] as? String ?? ""
        self.coverLetterURL = dictionary["coverLetterURL"] as? String ?? ""
        
        // load prompts from firestore
        if let promptDictionaries = dictionary["prompts"] as? [[String: Any]] {
            self.prompts = promptDictionaries.compactMap { Prompt(dictionary: $0) }
        } else {
            self.prompts = [] // default to empty
        }
        
        // load new stuff
        self.school = dictionary["school"] as? String ?? ""
        self.languages = dictionary["languages"] as? [String] ?? []
        self.certifications = dictionary["certifications"] as? [String] ?? []
        self.hobbies = dictionary["hobbies"] as? [String] ?? []
        self.avatarName = dictionary["avatarName"] as? String ?? "avatar_default"
    }
    
    // convert model to dictionary for firestore
    var dictionary: [String: Any] {
        return [
            "name": name,
            "phone": phone,
            "resumeURL": resumeURL,
            "coverLetterURL": coverLetterURL,
            // save prompts array
            "prompts": prompts.map { $0.dictionary },
            
            // save new stuff
            "school": school,
            "languages": languages,
            "certifications": certifications,
            "hobbies": hobbies,
            "avatarName": avatarName
        ]
    }
}
