//
//  Candidate.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import Foundation
import FirebaseFirestore

struct Prompt: Identifiable, Codable, Equatable {
    var id: String { question }
    let question: String
    var answer: String
    
    init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
    
    init?(dictionary: [String: Any]) {
        guard let question = dictionary["question"] as? String,
              let answer = dictionary["answer"] as? String else { return nil }
        self.question = question
        self.answer = answer
    }
    
    var dictionary: [String: Any] {
        return ["question": question, "answer": answer]
    }
}

struct Candidate: Identifiable, Equatable, Codable {
    
    @DocumentID var id: String?
    var name: String
    var phone: String
    var resumeURL: String
    var coverLetterURL: String
    var prompts: [Prompt]
    
    var school: String
    var languages: [String]
    var certifications: [String]
    var hobbies: [String]
    var avatarName: String
    
    init(id: String? = nil, name: String) {
        self.id = id
        self.name = name
        self.phone = ""
        self.resumeURL = ""
        self.coverLetterURL = ""
        self.prompts = []
        
        self.school = ""
        self.languages = []
        self.certifications = []
        self.hobbies = []
        self.avatarName = "avatar_default"
    }
    
    init(id: String, dictionary: [String: Any]) {
        self.id = id
        self.name = dictionary["name"] as? String ?? ""
        self.phone = dictionary["phone"] as? String ?? ""
        self.resumeURL = dictionary["resumeURL"] as? String ?? ""
        self.coverLetterURL = dictionary["coverLetterURL"] as? String ?? ""
        
        if let promptDictionaries = dictionary["prompts"] as? [[String: Any]] {
            self.prompts = promptDictionaries.compactMap { Prompt(dictionary: $0) }
        } else {
            self.prompts = []
        }
        
        self.school = dictionary["school"] as? String ?? ""
        self.languages = dictionary["languages"] as? [String] ?? []
        self.certifications = dictionary["certifications"] as? [String] ?? []
        self.hobbies = dictionary["hobbies"] as? [String] ?? []
        self.avatarName = dictionary["avatarName"] as? String ?? "avatar_default"
    }
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "phone": phone,
            "resumeURL": resumeURL,
            "coverLetterURL": coverLetterURL,
            "prompts": prompts.map { $0.dictionary },
            "school": school,
            "languages": languages,
            "certifications": certifications,
            "hobbies": hobbies,
            "avatarName": avatarName
        ]
    }
}
