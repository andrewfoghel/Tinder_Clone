//
//  MessageLogTableViewController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/4/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

class MessageLogTableViewController: UIViewController {
    var messages = [Message]()
    var messagesDictionary = [String : Message]()
    
    let cellId = "cell"
    let tvCellId = "tvCell"
    var matchedUsers = [MyUser]()
    //Non started messages
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    //startedMessages
    let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        return tv
    }()
    
    fileprivate func setupViews() {
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageViewCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 4, paddingLeft: 16, paddingRight: 16, paddingBottom: 0, width: 0, height: 75)
        
        view.addSubview(tableView)
        tableView.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 4, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: tvCellId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = offerBlack
        messages.removeAll()
        messagesDictionary.removeAll()
        setupViews()
        getUnstartedMessageProfiles()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        observeUserMessages()
    }
    
    var collectionTimer: Timer?
    var tableTimer: Timer?
    
    fileprivate func attemptCollectionViewReloadData() {
        collectionTimer?.invalidate()
        collectionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReloadCollection), userInfo: nil, repeats: false)
    }
    
    @objc fileprivate func handleReloadCollection() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    
    fileprivate func attemptTableViewReloadData() {
        tableTimer?.invalidate()
        self.tableTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTable(){
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (myMessage1, myMessage2) -> Bool in
            return Int((myMessage1.timestamp?.int64Value)!) > Int((myMessage2.timestamp?.int64Value)!)
        })
        
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    fileprivate func observeUserMessages() {
        DatabaseLayer.shared.observeUserMessages { (message, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            guard let message = message else { return }
            if let chatPartnerId = message.chatPartnerId() {
                self.messagesDictionary[chatPartnerId] = message
            }
            
            self.attemptTableViewReloadData()
        }
        
        DatabaseLayer.shared.observeRemovesMessages { (messageToRemove, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            guard let id = messageToRemove else { return }
            self.messagesDictionary.removeValue(forKey: id)
            self.attemptTableViewReloadData()
        }
        
    }
    
    var userToRemove = MyUser()
    fileprivate func getUnstartedMessageProfiles() {
        DatabaseLayer.shared.getUserLikes { (matchedUser, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            guard let user = matchedUser else { return }
            self.matchedUsers.append(user)
            self.attemptCollectionViewReloadData()
            guard let matchUid = user.uid else { return }
            DatabaseLayer.shared.setStartMessageObserver(matchUid: matchUid, completion: { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                
                guard let user = user else { return }
                self.userToRemove = user
                self.attemptRemoveUser()
            })
        }
    }
    
    var userDeleteTimer: Timer?
    fileprivate func attemptRemoveUser() {
        userDeleteTimer?.invalidate()
        userDeleteTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleRemoveUser), userInfo: nil, repeats: false)
    }
    
    @objc fileprivate func handleRemoveUser() {
        var count = 0
        for user in matchedUsers {
            if user.uid == userToRemove.uid {
                self.matchedUsers.remove(at: count)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            count += 1
        }
    }
}

extension MessageLogTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tvCellId, for: indexPath) as! UserCell
        cell.selectionStyle = .none
        cell.message = messages[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let message = self.messages[indexPath.row]
            if let chatPartnerId = message.chatPartnerId() {
                DatabaseLayer.shared.removeMessage(partnerUid: chatPartnerId, completion: { (success) in
                    if success {
                        self.messagesDictionary.removeValue(forKey: chatPartnerId)
                        self.attemptTableViewReloadData()
                    }
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        let chatPartnerId: String?
        if message.fromId == currentUser.uid {
            chatPartnerId = message.toId
        } else {
            chatPartnerId = message.fromId
        }
        guard let uid = chatPartnerId else { return }
        DatabaseLayer.shared.getCurrentUserData(uid: uid) { (user, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            guard let user = user else { return }
            let chatLog = ChatLogCollectionViewController()
            chatLog.selectedUser = user
       //     let navController = UINavigationController(rootViewController: chatLog)
            self.present(chatLog, animated: true, completion: nil)
            
        }
    }
    
}

extension MessageLogTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matchedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageViewCollectionViewCell
        let user = matchedUsers[indexPath.row]
        cell.imageView.loadImage(urlString: user.profileImageUrl!)
        cell.imageView.layer.cornerRadius = 25
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = matchedUsers[indexPath.item]
        let chatLog = ChatLogCollectionViewController()
        chatLog.selectedUser = user
     //   let navController = UINavigationController(rootViewController: chatLog)
        present(chatLog, animated: true, completion: nil)
    }
}



