//
//  MyUser.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/3/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import Foundation

class MyUser: NSObject {
    var uid: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
    var gender: String?
    var interested: String?
    var age: String?
    var lat: Double?
    var lon: Double?
    var index: Int?
    var autoIdIndex: String?
    
    convenience init(uid: String, name: String, email: String, profileImageUrl: String, gender: String, interested: String, birthday: String) {
        self.init()
        self.uid = uid
        self.name = name
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.gender = gender
        self.interested = interested
        self.age = birthday
    }
    
    convenience init(key: String, dictionary: [String : Any]) {
        self.init()
        self.uid = key
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.gender = dictionary["gender"] as? String ?? ""
        self.interested = dictionary["interested"] as? String ?? ""
        self.age = dictionary["birthday"] as? String ?? ""
        self.lat = dictionary["lat"] as? Double ?? 0.0
        self.lon = dictionary["lon"] as? Double ?? 0.0
    }
    
    var asJSON: [String : Any] {
        return ["name" : self.name ?? "", "email" : self.email ?? "", "gender" : self.gender ?? "", "interested" : self.interested ?? "", "birthday" : self.age ?? ""]
    }
    
    
}
