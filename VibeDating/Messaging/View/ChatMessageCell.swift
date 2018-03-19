//
//  ChatMessageCell.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/13/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    var message: Message?
    var chatLogController = ChatLogCollectionViewController()
    let activityMonitor: UIActivityIndicatorView = {
        let am = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        am.translatesAutoresizingMaskIntoConstraints = false
        am.hidesWhenStopped = true
        return am
    }()
    
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "sample text for now"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = UIColor.clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textColor = .white
        tv.isEditable = false
        return tv
    }()
    
    lazy var messageImageView: RoundImageView = {
        let imageView = RoundImageView(color: .clear, cornerRadius: 0)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return imageView
    }()
    
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer){
        if message?.videoUrl != nil{
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView{
            self.chatLogController.performZoomInForstartingImageView(startingImageView: imageView)
        }
    }
    
    static let blueColor = UIColor(red: 57/255, green: 169/255, blue: 249/255, alpha: 1)
    
    //set background
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    //constraints for profileimage
    
    let profileImageView = RoundImageView(color: .clear, cornerRadius: 16)
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(bubbleView)
        addSubview(textView)
        bubbleView.addSubview(messageImageView)
        
        profileImageView.anchor(top: nil, left: leftAnchor, right: nil, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 8, paddingRight: 0, paddingBottom: 0, width: 32, height: 32)
        
        
        messageImageView.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, right: nil, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        bubbleView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubbleView.addSubview(activityMonitor)
        activityMonitor.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityMonitor.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityMonitor.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityMonitor.heightAnchor.constraint(equalToConstant: 50).isActive = true
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playerLayer: AVPlayerLayer?
    var player:AVPlayer?
    @objc func handlePlay(){
        if let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString){
            player = AVPlayer(url: url)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player?.isMuted = false
            player?.play()
            self.activityMonitor.startAnimating()
            playButton.isHidden = true
            
            NotificationCenter.default.addObserver(self, selector: #selector(prepareForReuse), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        player?.isMuted = true
        activityMonitor.stopAnimating()
        playButton.isHidden = false
    }
    
}
