//
//  EditUserInfoViewController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/11/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

class EditUserInfoViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    //Edit Info View Controller
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let cellId = "cell"
    var cellToManipulate = ImageViewCollectionViewCell()

    var remainingCount = 250
    
    var cells = [ImageViewCollectionViewCell]()
    var imageUrls = [UserImage]()
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = offerBlack
        sv.keyboardDismissMode = .onDrag
        sv.showsVerticalScrollIndicator = false
        sv.bounces = false
        return sv
    }()

    let mainImageView = RoundImageView(color: .clear, cornerRadius: 0)
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = offBlack
        return view
    }()
    
    let uploadButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .lightGray
        btn.setImage(#imageLiteral(resourceName: "AddImage(Black)").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handlePhotoUpload), for: .touchUpInside)
        return btn
    }()
    
    @objc fileprivate func handlePhotoUpload() {
        let photoSelector = PhotoSelectorController(collectionViewLayout: UICollectionViewFlowLayout())
        photoSelector.editUserInfoViewController = self
      //  let navController = UINavigationController(rootViewController: photoSelector)
        present(photoSelector, animated: true, completion: nil)
    }
    
    let buttonItemView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let dismissViewButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .lightGray
        btn.setImage(#imageLiteral(resourceName: "Cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleDismissButtonView), for: .touchUpInside)
        return btn
    }()
    
    fileprivate func resetButtonViewTopAnchor() {
        buttonItemViewTopAnchor.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc fileprivate func handleDismissButtonView() {
       resetButtonViewTopAnchor()
    }
    
    let deletePhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .lightGray
        btn.setImage(#imageLiteral(resourceName: "DeleteImage").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handlePhotoDelete), for: .touchUpInside)
        return btn
    }()
    
    var index = 0
    @objc fileprivate func handlePhotoDelete() {
        resetButtonViewTopAnchor()
        if index == 0 {
            isProfileImage = true
        }
        DatabaseLayer.shared.deleteUserDatingImage(imageIndexId: imageUrls[index].id, isProfileImage: isProfileImage)
        imageUrls.remove(at: index)
        cells.removeAll()
        collectionView.isUserInteractionEnabled = false
        collectionView.setContentOffset(.zero, animated: true)
        collectionView.isUserInteractionEnabled = true
        mainImageView.loadImage(urlString: imageUrls[0].url)

        self.attemptReloadCollectionView()
    }
    
    var isBeingReplaced = false
    var isProfileImage = false
    let replacePhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .lightGray
        btn.setImage(#imageLiteral(resourceName: "ReplaceImage").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handlePhotoReplace), for: .touchUpInside)
        return btn
    }()
    
    @objc fileprivate func handlePhotoReplace() {
        isBeingReplaced = true
        if index == 0 {
            isProfileImage = true
        }
        resetButtonViewTopAnchor()
        handlePhotoUpload()
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.collectionViewLayout = layout
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = offBlack
        return cv
    }()

    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont(name: "Avenir Next", size: 14)
        tv.textColor = .white
        tv.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
        tv.layer.cornerRadius = 10
        tv.layer.masksToBounds = true
        return tv
    }()

    let remainingCountLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "Avenir Next", size: 14)
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        lbl.text = "250"
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    var buttonItemViewTopAnchor = NSLayoutConstraint()
    var scrollViewBottomAnchor = NSLayoutConstraint()
    
    let fillerView: UIView = {
        let view = UIView()
        view.backgroundColor = offBlack
        return view
    }()
    
    let navBar: UIView = {
        let view = UIView()
        view.backgroundColor = offBlack
        return view
    }()
    
    let doneButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Done", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        return btn
    }()
    
    fileprivate func setupImageViews() {
        view.addSubview(fillerView)
        fillerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        view.addSubview(navBar)
        navBar.anchor(top: fillerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 44)
        navBar.addSubview(doneButton)
        doneButton.anchor(top: nil, left: nil, right: view.rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 10, paddingBottom: 0, width: 50, height: 20)
        doneButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor).isActive = true
        
        view.addSubview(scrollView)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .black
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 44, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        scrollViewBottomAnchor = scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        scrollViewBottomAnchor.isActive = true
        scrollView.addSubview(mainImageView)

        if let url = currentUser.profileImageUrl {
            mainImageView.loadImage(urlString: url)
        }
        
        mainImageView.anchor(top: scrollView.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: self.view.frame.height / 2.165)
        
        scrollView.addSubview(buttonItemView)
        scrollView.addSubview(separatorView)
        scrollView.addSubview(uploadButton)
        scrollView.addSubview(collectionView)
        
        separatorView.anchor(top: mainImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 1)
        uploadButton.anchor(top: separatorView.bottomAnchor, left: view.leftAnchor, right: nil, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 80, height: 80)
        
        collectionView.anchor(top: separatorView.bottomAnchor, left: uploadButton.rightAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 80)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageViewCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        buttonItemView.anchor(top: nil, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: -50, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 70)
        buttonItemViewTopAnchor = buttonItemView.topAnchor.constraint(equalTo: collectionView.topAnchor)
        buttonItemViewTopAnchor.isActive = true
        
        buttonItemView.addSubview(dismissViewButton)
        dismissViewButton.anchor(top: buttonItemView.topAnchor, left: buttonItemView.leftAnchor, right: nil, bottom: buttonItemView.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: self.view.frame.width / 3, height: 0)
        
        buttonItemView.addSubview(replacePhotoButton)
        replacePhotoButton.anchor(top: buttonItemView.topAnchor, left: dismissViewButton.rightAnchor, right: nil, bottom: buttonItemView.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: self.view.frame.width / 3, height: 0)
        
        buttonItemView.addSubview(deletePhotoButton)
        deletePhotoButton.anchor(top: buttonItemView.topAnchor, left: replacePhotoButton.rightAnchor, right: nil, bottom: buttonItemView.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: self.view.frame.width / 3, height: 0)
        
        scrollView.addSubview(textView)
        textView.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 12, paddingLeft: 12, paddingRight: 12, paddingBottom: 0, width: 0, height: 150)
        textView.contentSize.height = 130
        textView.delegate = self
        
        scrollView.addSubview(remainingCountLabel)
        remainingCountLabel.anchor(top: nil, left: nil, right: textView.rightAnchor, bottom: textView.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 4, paddingBottom: 4, width: 30, height: 20)

//        scrollView.addSubview(topRightSecondaryImage)
//        scrollView.addSubview(midRightSecondaryImage)
//
//
//        mainImage.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: nil, bottom: nil, paddingTop: 12, paddingLeft: 12, paddingRight: 0, paddingBottom: 0, width: 225, height: 225)
//        topRightSecondaryImage.anchor(top: mainImage.topAnchor, left: mainImage.rightAnchor, right: nil, bottom: nil, paddingTop: 0, paddingLeft: 24, paddingRight: 0, paddingBottom: 0, width: 100, height: 100)
//        midRightSecondaryImage.anchor(top: topRightSecondaryImage.bottomAnchor, left: topRightSecondaryImage.leftAnchor, right: nil, bottom: nil, paddingTop: 18, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 100, height: 100)
//
//        lastRowOfImages()
//
//        imageArray = [mainImage, topRightSecondaryImage, midRightSecondaryImage, rightBottomSecondaryImage, midBottomSecondaryImage, leftBottomSecondaryImage]
//
//        for imageview in imageArray {
//            imageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddImage)))
//        }
//
//        scrollView.addSubview(textView)
//        textView.anchor(top: leftBottomSecondaryImage.bottomAnchor, left: leftBottomSecondaryImage.leftAnchor, right: rightBottomSecondaryImage.rightAnchor, bottom: nil, paddingTop: 12, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 140)
//        textView.delegate = self
//
//        scrollView.addSubview(remainingCountLabel)
//        remainingCountLabel.anchor(top: nil, left: nil, right: textView.rightAnchor, bottom: textView.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 4, paddingBottom: 4, width: 30, height: 20)
//
    }
    
    var scrollViewHeight:CGFloat = 0
    var keyboard = CGRect()
    fileprivate func setupKeyboardObservers() {
        scrollView.contentSize.height = self.view.frame.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 150
        scrollViewHeight = scrollView.frame.size.height
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChangeFrame), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc fileprivate func handleKeyboardWillHide(_ notification: Notification) {
        let contentInsets: UIEdgeInsets = .zero
        self.scrollView.contentInset = contentInsets
    }
    
    @objc fileprivate func handleKeyboardWillChangeFrame(_ notification: Notification) {
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboard.height, right: 0)
        self.scrollView.contentInset = contentInsets
        
        var rect = self.view.frame
        rect.size.height = self.view.frame.height - 44 - 20.0 - keyboard.height
        print(textView.frame.origin)
        if !rect.contains(self.textView.frame.origin) {
            let scrollPoint = CGPoint(x: 0.0, y: textView.frame.origin.y - (keyboard.height - 100))
            scrollView.setContentOffset(scrollPoint, animated: true)
        }

    }
    
    @objc fileprivate func handleDone() {
        if 250 - self.textView.text.count > 0 {
            print("Nice")
            DatabaseLayer.shared.saveUserBio(text: self.textView.text)
        } else {
            appDelegate.errorView(message: "Bio text is too long please make it shorter", color: .red)
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
//    fileprivate func lastRowOfImages() {
//        let stackView = UIStackView(arrangedSubviews: [leftBottomSecondaryImage, midBottomSecondaryImage, rightBottomSecondaryImage])
//        stackView.axis = .horizontal
//        stackView.distribution = .fillEqually
//        stackView.spacing = 24
//        scrollView.addSubview(stackView)
//        stackView.anchor(top: mainImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 12, paddingLeft: 12, paddingRight: 12, paddingBottom: 0, width: 0, height: 100)
//
//    }
    
    func getUserImages() {
        guard let uid = currentUser.uid else { return }
        DatabaseLayer.shared.getCurrentUserImages { (userImage, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            guard let img = userImage else { return }
            self.imageUrls.append(img)
            self.attemptReloadCollectionView()
        }
        
//        DatabaseLayer.shared.getUserImages(uid: uid) { (values, error) in
//            if let err = error {
//                print(err.localizedDescription)
//                return
//            }
//            guard let key = values?.first?.key else { return }
//            guard let url = values?.first?.value else { return }
//            let userImage = UserImage(id: key, url: url)
//            self.imageUrls.append(userImage)
//            self.attemptReloadCollectionView()
//        }
    }
    
    var timer: Timer?
    fileprivate func attemptReloadCollectionView() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (_) in
            self.collectionView.reloadData()
        })
    }
    
    fileprivate func getUserBio() {
        guard let uid = currentUser.uid else { return }
        DatabaseLayer.shared.getUserBio(uid: uid) { (bio, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            guard let bio = bio else { return }
            self.textView.text = bio
            self.remainingCountLabel.text = "\(250 - self.textView.text.count)"
            
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isProfileImage = false
        isBeingReplaced = false
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
//        print("NavBAR: \(self.navigationController?.navigationBar.frame.height)")
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        transitioningDelegate = self
        view.backgroundColor = offerBlack
        setupImageViews()
        getUserImages()
        getUserBio()
        setupKeyboardObservers()
    }
    
    let customAnimationPresenter = CustomAnimationPresenter()
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return customAnimationPresenter
    }
    
    let customAnimationDismisser = CustomAnimationDismisser()
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
    
}

extension EditUserInfoViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageViewCollectionViewCell
        let userImage = imageUrls[indexPath.item]
        cell.userImage = userImage
        cell.imageView.loadImage(urlString: userImage.url)
        cells.append(cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.item
        isProfileImage = false
        isBeingReplaced = false
        cellToManipulate = cells[indexPath.item]
        var userImage = imageUrls[indexPath.item]
        mainImageView.loadImage(urlString: userImage.url)
        buttonItemViewTopAnchor.constant = -70
        isProfileImage = false  
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        //ADD SOME ALPHA VIEW ATOP IMAGEVIEW
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}

extension EditUserInfoViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let charCount = textView.text.count
        let remainingCount = 250 - charCount
        if remainingCount < 0 {
            self.remainingCountLabel.textColor = .red
            self.remainingCountLabel.text = "\(remainingCount)"
        } else {
            self.remainingCountLabel.textColor = .white
            self.remainingCountLabel.text = "\(remainingCount)"
        }

        print(remainingCount)
    }
}

