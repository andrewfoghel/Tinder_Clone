//
//  UserCell.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/13/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    var message:Message?{
        didSet{
            self.setupName()
            
            self.detailTextLabel?.text = message?.text
            if let seconds = message?.timestamp?.doubleValue{
                let timeStampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.string(from: timeStampDate)
            }
            
        }
    }
    
    private func setupName(){
        let chatPartnerId: String?
        if message?.fromId == currentUser.uid {
            chatPartnerId = message?.toId
        }else{
            chatPartnerId = message?.fromId
        }
        
        if let id = chatPartnerId {
            DatabaseLayer.shared.getCurrentUserData(uid: id, completion: { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                guard let user = user, let name = user.name, let url = user.profileImageUrl else { return }
                self.textLabel?.text = name
                self.profileImageView.loadImage(urlString: url)
            })
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.frame.width
        textLabel?.frame = CGRect(x: width/6, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        textLabel?.textColor = .white
        detailTextLabel?.frame = CGRect(x: width/6, y: detailTextLabel!.frame.origin.y, width: detailTextLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.textColor = .white 
    }
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let profileImageView = RoundImageView(color: .clear, cornerRadius: 20)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        addSubview(timeLabel)
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.anchor(top: nil, left: leftAnchor, right: nil, bottom: nil, paddingTop: 0, paddingLeft: 8, paddingRight: 0, paddingBottom: 0, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        timeLabel.anchor(top: topAnchor, left: nil, right: rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 100, height: (textLabel?.frame.height)!)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

