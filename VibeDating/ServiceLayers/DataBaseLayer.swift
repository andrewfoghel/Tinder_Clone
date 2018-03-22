//
//  DataBaseLayer.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/3/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class DatabaseLayer {
    static let shared = DatabaseLayer()
    
    func saveUserData(user: MyUser) {
        guard let uid = user.uid else { return }
        
        guard let gender = user.gender else { return }
        if gender.lowercased() == "female" {
            Database.database().reference().child("female-users").childByAutoId().setValue(uid, withCompletionBlock: { (error, _) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
            })
        } else if gender.lowercased() == "male" {
            Database.database().reference().child("male-users").childByAutoId().setValue(uid, withCompletionBlock: { (error, _) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
            })
        }
        
        Database.database().reference().child("users").child(uid).updateChildValues(user.asJSON, withCompletionBlock: { (error, _) in
            if let err = error {
                print("Error saving user data: ", err.localizedDescription)
                return
            }
        })

        if let url = user.profileImageUrl {
            Database.database().reference().child("user-images").child(uid).childByAutoId().setValue(user.profileImageUrl, withCompletionBlock: { (error, _) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
            })
            
            Database.database().reference().child("users").child(uid).child("profileImageUrl").setValue(user.profileImageUrl, withCompletionBlock: { (error, _) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
            })
            
        }
    }
    
    func saveUserLocation(lat: Double, lon: Double) {
        guard let uid = currentUser.uid else { return }
        let values: [String : Any] = ["lat" : lat, "lon" : lon]
        Database.database().reference().child("users").child(uid).updateChildValues(values) { (error, _) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
        }
    }
    
    func getCurrentUserData(uid: String, indexUid: String? = nil, completion: @escaping (MyUser?, Error?) -> ()){
        var user: MyUser?
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : Any] {
                user = MyUser(key: snapshot.key, dictionary: dictionary)
                if let autoIndexUid = indexUid {
                    user?.autoIdIndex = autoIndexUid
                }
                completion(user, nil)
            }
        }) { (err) in
            print("Error fetching user data: ", err.localizedDescription)
            completion(nil, err)
        }
    }
    
    func setProfileImageObserver(completion: @escaping (String?, Error?) -> ()) {
        guard let uid = currentUser.uid else { return }
        Database.database().reference().child("users").child(uid).child("profileImageUrl").observe(.value, with: { (snapshot) in
            guard let url = snapshot.value as? String else { return }
            completion(url, nil)
        }) { (error) in
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    func getUserDataOrAutoUid(uid: String?, indexUid: String? = nil, completion: @escaping (MyUser?, String?, Error?) -> ()) {
        var user: MyUser?
        guard let uid = uid else {
            completion(nil, indexUid, nil)
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : Any] {
                user = MyUser(key: snapshot.key, dictionary: dictionary)
                if let autoIndexUid = indexUid {
                    user?.autoIdIndex = autoIndexUid
                }
                guard let user = user else { return }
                
               // guard let userLat = user.lat, let userLon = user.lon else { return }
               // let currentUserLocation = CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
               // let userLocation = CLLocation(latitude: userLat, longitude: userLon)
                if user.interested == currentUser.gender && user.gender == currentUser.interested /*&& currentUserLocation.distance(from: userLocation) < 16093.4 TEN MILE RADIUS MATCH*/{
                    //Handle Age here as well
                    self.count += 1
                    completion(user, indexUid, nil)
                }
            }
        }) { (err) in
            print("Error fetching user data: ", err.localizedDescription)
            completion(nil, nil, err)
        }
    }
    

    func saveUserDatingImage(image: UIImage, completion: @escaping (UserImage?, Error?) -> ()) {
        StorageLayer.shared.saveImage(folderPath: "dating_profile_images", image: image) { (downloadUrl, error) in
            if let err = error {
                print("Error Saving additional profile image: ", err.localizedDescription)
                completion(nil, err)
                return
            }
            
            //Save user image here
            guard let url = downloadUrl else { return }
            guard let uid = currentUser.uid else { return }
            
            Database.database().reference().child("user-images").child(uid).childByAutoId().setValue(url, withCompletionBlock: { (error, ref) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
            
                let userImage = UserImage(id: ref.key, url: url)
                completion(userImage, nil)
                
            })
        }
    }
    
    func deleteUserDatingImage(imageIndexId: String, isProfileImage: Bool) {
        guard let uid = currentUser.uid else { return }
        Database.database().reference().child("user-images").child(uid).child(imageIndexId).removeValue { (error, _) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            if isProfileImage == true {
                Database.database().reference().child("user-images").child(uid).queryOrderedByKey().queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot.value)
                    if let dictionary = snapshot.value as? [String : Any] {
                        guard let url = dictionary.first?.value as? String else { return }
                        currentUser.profileImageUrl = url
                        Database.database().reference().child("users").child(uid).child("profileImageUrl").setValue(url, withCompletionBlock: { (error, _) in
                            if let err = error {
                                print(err.localizedDescription)
                                return
                            }
                        })
                    }
                })
            }
        }
    }
    
    func updateUserImage(imageIndexId: String, image: UIImage, isProfileImage: Bool, completion: @escaping (String?, Error?) -> ()) {
        guard let uid = currentUser.uid else { return }
        StorageLayer.shared.saveImage(folderPath: "dating_profile_images", image: image) { (downloadUrl, error) in
            if let err = error {
                print(err.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let url = downloadUrl else { return }
            
            if isProfileImage == true {
                Database.database().reference().child("users").child(uid).child("profileImageUrl").setValue(url, withCompletionBlock: { (error, _) in
                    if let err = error {
                        print(err.localizedDescription)
                        return
                    }
                    currentUser.profileImageUrl = url
                    completion(url, nil)
                })
            }
            
            Database.database().reference().child("user-images").child(uid).child(imageIndexId).setValue(url, withCompletionBlock: { (error, _) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                completion(url, nil)
            })
        }
    }
    
    func getCurrentUserImages(completion: @escaping (UserImage?, Error?) -> ()) {
        guard let uid = currentUser.uid else { return }
        Database.database().reference().child("user-images").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                snapshot.forEach({ (snap) in
                    guard let url = snap.value as? String else { return }
                    let userImage = UserImage(id: snap.key, url: url)
                    completion(userImage, nil)
                })
            }
//            guard let url = snapshot.value as? String else { return }
//            let userImage = UserImage(id: snapshot.key, url: url)
//            completion(userImage, nil)
        }) { (error) in
            completion(nil, error)
        }
    }
    
    func getUserImages(uid: String, completion: @escaping ([String : String]?, Error?) -> ()) {
        Database.database().reference().child("user-images").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                snapshot.forEach({ (snap) in
                    guard let url = snap.value as? String else { return }
                    var dictionary = [snap.key : url]
                    completion(dictionary, nil)
                })
            }
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for snap in snapshot {
//                    let value = [snap.key : snap.value as! String]
//                    completion(value, nil)
//                }
//            }
        }) { (error) in
            completion(nil, error)
            print(error.localizedDescription)
        }
    }
    
    func saveUserBio(text: String) {
        guard let uid = currentUser.uid else { return }
        let values: [String : Any] = ["bio" : text]
        Database.database().reference().child("user-bios").child(uid).updateChildValues(values) { (error, _) in
            if let err = error {
                print(err.localizedDescription)
            }
        }
    }
    
    func getUserBio(uid: String, completion: @escaping (String?, Error?) -> ()) {
        Database.database().reference().child("user-bios").child(uid).child("bio").observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.value as? String, nil)
        }) { (error) in
            completion(nil, error)
        }
    }
    
    func getUsersToMatchData(completion: @escaping (MyUser?, String?, Error?) -> ()) {
        guard let interested = currentUser.interested else { return }
        let str = interested + "-users"
        
        Database.database().reference().child(str).queryOrderedByKey().queryLimited(toLast: 15).observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                firstAutoIdIndex = snapshot.first?.key
                snapshot.forEach({ (snap) in
                    guard let matchUid = snap.value as? String else { return }
                    self.checkForPreviouslyInteractedWithUser(matchUid: matchUid, indexUid: snap.key, completion: completion)
                })
            }
        }
    }
    
    var count = 0
    var timer: Timer?
    func fetchMoreUsersForLoading(indexUid: String, fetchAmount: UInt, completion: @escaping (MyUser?, String?, Error?) -> ()) {
        guard let interested = currentUser.interested else { return }
        let str = interested + "-users"
        
        count = 0
        
        Database.database().reference().child(str).queryOrderedByKey().queryEnding(atValue: indexUid).queryLimited(toLast: fetchAmount).observeSingleEvent(of: .value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                firstAutoIdIndex = snapshot.first?.key
                
                var previousUid = String()
                snapshot.forEach({ (snap) in
                    guard let uid = snap.value as? String else { return }
                    if snap.key != indexUid && uid != previousUid {
                        guard let matchUid = snap.value as? String else { return }
                        previousUid = snap.value as! String
                        self.checkForPreviouslyInteractedWithUser(matchUid: matchUid, indexUid: snap.key, completion: completion)
                    }
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (_) in
                        if self.count < 4 && firstAutoIdIndex != snapshot.last?.key {
                            guard let firstIndex = firstAutoIdIndex else { return }
                            self.fetchMoreUsersForLoading(indexUid: firstIndex, fetchAmount: 15, completion: completion)
                        }
                    })
                })
            }
        }
    }
    
    func checkForPreviouslyInteractedWithUser(matchUid: String, indexUid: String ,completion: @escaping (MyUser?, String?, Error?) -> ()) {
        guard let uid = currentUser.uid else { return }
        
        Database.database().reference().child("user-match-ref").child(uid).child(matchUid).observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? Int {
                self.getUserDataOrAutoUid(uid: nil, indexUid: indexUid, completion: completion)
            } else {
                self.getUserDataOrAutoUid(uid: matchUid, indexUid: indexUid, completion: completion)
            }
        }
    }
    
    func saveUserLikeData(matchUid: String, completion: @escaping (MyUser?, Error?) -> ()) {
        guard let uid = currentUser.uid else { return }
        Database.database().reference().child("user-match-ref").child(uid).child(matchUid).setValue(1) { (error, _) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            //CHECK FOR INSTANT MATCH HERE
            self.checkForMutualLikes(matchUid: matchUid, completion: completion)
        }
    }
    
    func saveUserDislikeData(matchUid: String) {
        guard let uid = currentUser.uid else { return }
        Database.database().reference().child("user-match-ref").child(uid).child(matchUid).setValue(0) { (error, _) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
        }
        
        //set the user value to zero as well by default for loading purpose perhaps will not load the users who don't like you
        Database.database().reference().child("user-match-ref").child(matchUid).child(uid).setValue(0) { (error, _) in
            if let err = error {
                print(err.localizedDescription)
            }
        }
    }
    
    func getUserLikes(completion: @escaping (MyUser?, Error?) -> ()) {
        guard let uid = currentUser.uid else { return }
        Database.database().reference().child("user-match-ref").child(uid).observe(.childAdded, with: { (snapshot) in
            guard let isMatch = snapshot.value as? Int else { return }
            if isMatch == 1 {
                self.checkForMutualLikes(matchUid: snapshot.key, completion: completion)
            }
        }) { (error) in
            completion(nil, error)
        }
    }
    
    func checkForMutualLikes(matchUid: String, completion: @escaping (MyUser?, Error?) -> ()) {
        guard let uid = currentUser.uid else { return }
        
        Database.database().reference().child("user-match-ref").child(matchUid).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let isMatch = snapshot.value as? Int else { return }
            if isMatch == 1 {
                self.getCurrentUserData(uid: matchUid, completion: completion)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func setStartMessageObserver(matchUid: String, completion: @escaping (MyUser?, Error?) -> ()) {
        guard let uid = currentUser.uid else { return }
        Database.database().reference().child("user-match-ref").child(uid).child(matchUid).observe(.value, with: { (snapshot) in
            guard let flag = snapshot.value as? Int else { return }
            if flag == 0 {
                self.getCurrentUserData(uid: snapshot.key, completion: completion)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    func observeUserMessages(completion: @escaping (Message?, Error?) -> ()) {
        guard let uid = currentUser.uid else { return }
        Database.database().reference().child("user-messages").child(uid).observe(.childAdded, with: { (snapshot) in
            self.observeMessageIds(userId: snapshot.key, completion: completion)
        }) { (error) in
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    func observeMessageIds(userId: String, completion: @escaping (Message?, Error?) -> ()) {
        guard let uid = currentUser.uid else { return }
        Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
            self.fetchMessage(messageId: snapshot.key, completion: completion)
        }, withCancel: { (error) in
            print(error.localizedDescription)
            completion(nil, error)
        })
    }
    
    func fetchMessage(messageId: String, completion: @escaping (Message?, Error?) -> ()) {
        Database.database().reference().child("messages").child(messageId).observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : Any] {
                let message = Message(dictionary: dictionary)
                completion(message, nil)
            }
        }) { (error) in
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    func observeRemovesMessages(completion: @escaping (String?, Error?) -> ()) {
        guard let uid = currentUser.uid else { return }
        Database.database().reference().child("user-messages").child(uid).observe(.childRemoved, with: { (snapshot) in
            completion(snapshot.key, nil)
        }) { (error) in
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    func removeMessage(partnerUid: String, completion: @escaping (Bool) -> ()) {
        guard let uid = currentUser.uid else { return }
        Database.database().reference().child("user-messages").child(uid).child(partnerUid).removeValue { (error, _) in
            if let err = error {
                print(err.localizedDescription)
                completion(false)
                return
            }
            completion(true)
        }
        
        Database.database().reference().child("user-messages").child(partnerUid).child(uid).removeValue { (error, _) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
        }
        
        Database.database().reference().child("user-match-ref").child(uid).child(partnerUid).removeValue { (error, _) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
        }
        
        Database.database().reference().child("user-match-ref").child(partnerUid).child(uid).removeValue { (error, _) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
        }
    }
    
    func sendMessageWithProperties(toId: String, properties: [String : Any], completion: @escaping (Bool) -> ()) {
        guard let fromId = currentUser.uid else { return }
        let timestamp = Date().timeIntervalSince1970
        var values: [String : Any] = ["toId" : toId, "fromId" : fromId, "timestamp" : timestamp] as [String : Any]
        properties.forEach({values[$0] = $1})
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        childRef.updateChildValues(values) { (error, _) in
            if let err = error {
                print(err.localizedDescription)
                completion(false)
                return
            }
            
            Database.database().reference().child("user-messages").child(fromId).child(toId).updateChildValues([childRef.key : 1], withCompletionBlock: { (error, _) in
                if let err = error {
                    print(err.localizedDescription)
                    completion(false)
                    return
                }
            })
            
            Database.database().reference().child("user-match-ref").child(fromId).child(toId).setValue(0, withCompletionBlock: { (error, _) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
            })
            
            Database.database().reference().child("user-messages").child(toId).child(fromId).updateChildValues([childRef.key : 1], withCompletionBlock: { (error, _) in
                if let err = error {
                    print(err.localizedDescription)
                    completion(false)
                    return
                }
            })
            
            Database.database().reference().child("user-match-ref").child(toId).child(fromId).setValue(0, withCompletionBlock: { (error, _) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
            })
            
            completion(true)
        }
    }
    
    func observeChatMessageIds(partnerId: String, completion: @escaping (Message?, Error?) -> ()) {
        guard let uid = currentUser.uid else { return }
        Database.database().reference().child("user-messages").child(uid).child(partnerId).observe(.childAdded, with: { (snapshot) in
            self.observeChatMessage(id: snapshot.key, completion: completion)
        }) { (error) in
            completion(nil, error)
        }
    }
    
    func observeChatMessage(id: String, completion: @escaping (Message?, Error?) -> ()) {
        Database.database().reference().child("messages").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any] else { return }
            let message = Message(dictionary: dictionary)
            completion(message, nil)
        }) { (error) in
            completion(nil, error)
        }
    }
    
}
