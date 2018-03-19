//
//  ChatLogViewController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/13/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

class ChatLogCollectionViewController: UIViewController {
    var selectedUser: MyUser?
    
    let cellId = "cell"
    
    var messages = [Message]()
    
    let inputContainer: ChatInputContainerView = {
        var chatInputContainer = ChatInputContainerView()
        return chatInputContainer
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        cv.keyboardDismissMode = .onDrag
        cv.alwaysBounceVertical = true
        cv.backgroundColor = offerBlack
        return cv
    }()
    
    fileprivate func setupNavigationItems() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        self.navigationItem.title = selectedUser?.name
        self.navigationController?.navigationBar.barTintColor = .black  
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    var bottomConstraint = NSLayoutConstraint()
    var textViewHeightConstraint = NSLayoutConstraint()
    var containerViewHeightConstraint = NSLayoutConstraint()
    fileprivate func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(inputContainer)
        
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 50, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        inputContainer.chatLogController = self
        inputContainer.anchor(top: nil, left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        containerViewHeightConstraint = inputContainer.heightAnchor.constraint(equalToConstant: 50)
        containerViewHeightConstraint.isActive = true
        
        textViewHeightConstraint = inputContainer.textViewHeightConstraint
        inputContainer.inputTextView.delegate = self
        bottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        bottomConstraint.isActive = true
        
        
        
        let fillerView = UIView()
        fillerView.backgroundColor = inputContainer.backgroundColor
        view.addSubview(fillerView)
        fillerView.anchor(top: inputContainer.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: self.view.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
  
    }
    
    @objc fileprivate func handleBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleUploadTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleSend(){
        let properties: [String : Any] = ["text" : inputContainer.inputTextView.text as Any]
        sendMessageWithProperties(properties: properties)
    }
    
    fileprivate func sendMessageWithProperties(properties: [String : Any]){
        guard let toId = selectedUser?.uid else { return }
        DatabaseLayer.shared.sendMessageWithProperties(toId: toId, properties: properties) { (success) in
            if success {
                self.inputContainer.inputTextView.text = nil
            } else {
                print("Unable to send message")
            }
        }
    }
    var chatInputOriginalHeight: CGFloat = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
        setupNavigationItems()
        setupKeyboardObservers()
        setupViews()
        observeMessages()
        chatInputOriginalHeight = self.inputContainer.frame.height
    }
  
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    @objc fileprivate func handleKeyboardDidShow(){
        if messages.count > 0{
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }

    fileprivate func adjustScrollView(with constant: CGFloat) {
        let adjustedConstant = constant - view.safeAreaInsets.bottom
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: adjustedConstant, right: 0)
        collectionView.contentInset = insets
        collectionView.scrollIndicatorInsets = insets
    }
    
    fileprivate func adjustBottomConstraint(to constant: CGFloat) {
        bottomConstraint.constant = constant
        UIView.animateKeyframes(withDuration: 0.25, delay: 0.0, options: [], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keyboardWillChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            var keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            else { return }
        adjustScrollView(with: keyboardFrame.height)
        let bottomInset = view.safeAreaInsets.bottom
        keyboardFrame.size.height -= bottomInset
        adjustBottomConstraint(to: -keyboardFrame.height)
    }
    
    @objc func keyboardWillHide() {
        adjustBottomConstraint(to: 0)
        adjustScrollView(with: 36)
    }
    
    fileprivate func observeMessages() {
        guard let chatPartnerId = selectedUser?.uid else { return }
        DatabaseLayer.shared.observeChatMessageIds(partnerId: chatPartnerId) { (message, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            guard let message = message else { return }
            self.messages.append(message)
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    var startingFrame: CGRect?
    var blackBackGround: UIView?
    var startingImageView: UIImageView?
    func performZoomInForstartingImageView(startingImageView: UIImageView){
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow{
            
            
            blackBackGround = UIView(frame: keyWindow.frame)
            blackBackGround?.backgroundColor = .black
            blackBackGround?.alpha = 0
            keyWindow.addSubview(blackBackGround!)
            
            keyWindow.addSubview(zoomingImageView)
            
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                self.blackBackGround?.alpha = 1
                self.inputContainer.alpha = 0
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: { (completed) in
                
            })
            
            
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view{
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackGround?.alpha = 0
                self.inputContainer.alpha = 1
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
}

extension ChatLogCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        let message = messages[indexPath.row]
        setupCell(cell: cell, message: message)
        
        cell.textView.text = message.text
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else  if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message){
        guard let user = selectedUser else { return }
        if let url = user.profileImageUrl {
            cell.profileImageView.loadImage(urlString: url)
        }
        
        cell.message = message
        
        if message.fromId == currentUser.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
            cell.textView.textColor = .white
            
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
            cell.profileImageView.isHidden = true
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
            cell.textView.textColor = .black
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
            cell.profileImageView.isHidden = false
        }
        
        if let messageUrl = message.imageUrl {
            cell.messageImageView.loadImage(urlString: messageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80

        let message = messages[indexPath.item]
        if let text = messages[indexPath.item].text{
            height = estimateFrameForText(text: text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue, let imageheight = message.imageHeight?.floatValue{
            height =  CGFloat(imageheight / imageWidth * 200)
        }

        let width = self.view.frame.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String)->CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        print("did end")
    }
}

extension ChatLogCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL{
            StorageLayer.shared.saveVideo(folderPath: "videos", url: videoUrl, completion: { (properties, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                guard let properties = properties else { return }
                self.sendMessageWithProperties(properties: properties)
            })
        } else {
            if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
                selectedImageFromPicker = editedImage
            }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
                selectedImageFromPicker = originalImage
            }
            
            if let selectedImage = selectedImageFromPicker {
                StorageLayer.shared.saveImage(folderPath: "message_images", image: selectedImage, completion: { (imageUrl, error) in
                    if let err = error {
                        print(err.localizedDescription)
                        return
                    }
                    guard let url = imageUrl else { return }
                    self.sendMessageWithImage(imageUrl: url, image: selectedImage)
                })
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func sendMessageWithImage(imageUrl: String, image: UIImage) {
        let properties: [String : Any] = ["imageUrl":imageUrl as Any,"imageWidth":image.size.width as Any,"imageHeight":image.size.height as Any]
        sendMessageWithProperties(properties: properties)
    }
}

extension ChatLogCollectionViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        updateTextView(forceSmall: false)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateTextView(forceSmall: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let inputTextView = inputContainer.inputTextView
        if inputTextView == textView {
            if textView.contentSize.height > 36 {
                updateTextView(forceSmall: false)
            }else{
                updateTextView(forceSmall: true)
            }
        }
    }
    
    fileprivate func updateTextView(forceSmall: Bool = false) {
        let inputTextView = inputContainer.inputTextView
        if forceSmall {
            self.textViewHeightConstraint.constant = 36
            self.containerViewHeightConstraint.constant = 50
        } else {
            if inputTextView.contentSize.height < 250 {
                var size: CGFloat = 0.0
                if inputTextView.contentSize.height < 36 {
                    size = 36
                } else {
                    size = inputTextView.contentSize.height
                }
                self.textViewHeightConstraint.constant = size
                self.containerViewHeightConstraint.constant = size + 14
                inputTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            } else {
                self.textViewHeightConstraint.constant = 250
                self.containerViewHeightConstraint.constant = 264
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}


