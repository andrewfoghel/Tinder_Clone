//
//  AuthLayer.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/3/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit
import Firebase

class AuthLayer {
    static let shared = AuthLayer()
    
    var myUser: User? {
        return Auth.auth().currentUser ?? nil
    }
    
    func createUser(email: String, password: String, name: String, image: UIImage, gender: String, interested: String, birthday: String, completion: @escaping (Bool, Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print("There was an error creating the user: ", err.localizedDescription)
                completion(false, err)
                return
            }
            
            guard let user = user else { return }
            
            StorageLayer.shared.saveImage(folderPath: "profile_images", image: image, completion: { (downloadUrl, error) in
                if let err = error {
                    print("Error Saving Profile Image: ", err.localizedDescription)
                    completion(false, err)
                    return
                }
                
                guard let url = downloadUrl else { return }
                currentUser = MyUser(uid: user.uid, name: name, email: email, profileImageUrl: url, gender: gender, interested: interested, birthday: birthday)
                DatabaseLayer.shared.saveUserData(user: currentUser)
                completion(true, nil)
            })
        }
    }
    
    func handleLogin(email: String, password: String, completion: @escaping (MyUser?, Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print("Error Signing In: ", err.localizedDescription)
                completion(nil, err)
            }
            guard let user = user else { completion(nil, nil); return }
            DatabaseLayer.shared.getCurrentUserData(uid: user.uid, completion: completion)
        }
    }
    
    func handleLogout(completion: @escaping () -> ()) {
        do {
            try Auth.auth().signOut()
            completion()
        } catch {
            print("Failed to logout: ", error.localizedDescription)
        }
    }
    
    func getUser(completion: @escaping (MyUser?, Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DatabaseLayer.shared.getCurrentUserData(uid: uid) { (user, error) in
            if let err = error {
                print("Error getting users data: ", err.localizedDescription)
                completion(nil, err)
                return
            }
            
            guard let user = user else { return }
            completion(user, nil)
        }
    }
}




