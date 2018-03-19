//
//  ChatInputContainerView.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/13/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView {
    
    var chatLogController: ChatLogCollectionViewController? {
        didSet{
            sendBtn.addTarget(chatLogController, action: #selector(ChatLogCollectionViewController.handleSend), for: .touchUpInside)
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogCollectionViewController.handleUploadTap)))
        }
    }
    
    var textViewHeightConstraint = NSLayoutConstraint()
    
    lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        textView.textColor = .white
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 10
        textView.layer.masksToBounds = true
        textView.autocorrectionType = .no
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.tintColor = .white
        textView.keyboardAppearance = .dark
        return textView
    }()
    
    let uploadImageView = RoundImageView(color: .clear, cornerRadius: 0)
    
    let sendBtn: UIButton = {
        let sendBtn = UIButton(type: .system)
        sendBtn.setTitle("Send", for: .normal)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        return sendBtn
    }()
    
    let separator: UIView = {
        let separator = UIView()
        separator.backgroundColor =  UIColor.lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    var containerHeightAnchor = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = offBlack
  
        addSubview(uploadImageView)
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.anchor(top: nil, left: leftAnchor, right: nil, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 4, paddingRight: 0, paddingBottom: 7.5, width: 35, height: 35)
        
        addSubview(sendBtn)
        
        sendBtn.anchor(top: nil, left: nil, right: rightAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 80, height: 50)
        
        addSubview(self.inputTextView)
        
        inputTextView.anchor(top: nil, left: uploadImageView.rightAnchor, right: sendBtn.leftAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 8, paddingRight: 0, paddingBottom: 7, width: 0, height: 0)
        textViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: 36)
        textViewHeightConstraint.isActive = true
        
        addSubview(separator)
        separator.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 1)
 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
}
