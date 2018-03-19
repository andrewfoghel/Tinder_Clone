//
//  EditUserInfoViewController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/11/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

class EditUserInfoViewController: UIViewController {
    
    //Edit Info View Controller
    
    var remainingCount = 250
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = offerBlack
        return sv
    }()
    
    let mainImage = RoundImageView(color: .clear, cornerRadius: 10, tag: 0)
    let topRightSecondaryImage = RoundImageView(color: .clear, cornerRadius: 10, tag: 1)
    let midRightSecondaryImage = RoundImageView(color: .clear, cornerRadius: 10, tag: 2)
    let rightBottomSecondaryImage = RoundImageView(color: .clear, cornerRadius: 10, tag: 3)
    let midBottomSecondaryImage = RoundImageView(color: .clear, cornerRadius: 10, tag: 4)
    let leftBottomSecondaryImage = RoundImageView(color: .clear, cornerRadius: 10, tag: 5)

    
    var imageArray = [RoundImageView]()

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
    
    fileprivate func setupImageViews() {
        view.addSubview(scrollView)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .black
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: 1000)
        scrollView.addSubview(mainImage)
        if let url = currentUser.profileImageUrl {
            mainImage.loadImage(urlString: url)
        }
        scrollView.addSubview(topRightSecondaryImage)
        scrollView.addSubview(midRightSecondaryImage)
        
        
        mainImage.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: nil, bottom: nil, paddingTop: 12, paddingLeft: 12, paddingRight: 0, paddingBottom: 0, width: 225, height: 225)
        topRightSecondaryImage.anchor(top: mainImage.topAnchor, left: mainImage.rightAnchor, right: nil, bottom: nil, paddingTop: 0, paddingLeft: 24, paddingRight: 0, paddingBottom: 0, width: 100, height: 100)
        midRightSecondaryImage.anchor(top: topRightSecondaryImage.bottomAnchor, left: topRightSecondaryImage.leftAnchor, right: nil, bottom: nil, paddingTop: 18, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 100, height: 100)
        
        lastRowOfImages()
        
        imageArray = [mainImage, topRightSecondaryImage, midRightSecondaryImage, rightBottomSecondaryImage, midBottomSecondaryImage, leftBottomSecondaryImage]
        
        for imageview in imageArray {
            imageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddImage)))
        }
        
        scrollView.addSubview(textView)
        textView.anchor(top: leftBottomSecondaryImage.bottomAnchor, left: leftBottomSecondaryImage.leftAnchor, right: rightBottomSecondaryImage.rightAnchor, bottom: nil, paddingTop: 12, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 140)
        textView.delegate = self
        
        scrollView.addSubview(remainingCountLabel)
        remainingCountLabel.anchor(top: nil, left: nil, right: textView.rightAnchor, bottom: textView.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 4, paddingBottom: 4, width: 30, height: 20)
        
    }
    
    @objc fileprivate func handleDone() {
        if 250 - self.textView.text.count > 0 {
            print("Nice")
            DatabaseLayer.shared.saveUserBio(text: self.textView.text)
        } else {
            //Handle Bio Too long error
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func lastRowOfImages() {
        let stackView = UIStackView(arrangedSubviews: [leftBottomSecondaryImage, midBottomSecondaryImage, rightBottomSecondaryImage])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 24
        scrollView.addSubview(stackView)
        stackView.anchor(top: mainImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 12, paddingLeft: 12, paddingRight: 12, paddingBottom: 0, width: 0, height: 100)
        
    }
    
    @objc fileprivate func handleAddImage(gesture: UITapGestureRecognizer) {
        let photoSelector = PhotoSelectorController(collectionViewLayout: UICollectionViewFlowLayout())
        guard let imageView = gesture.view as? UIImageView else { return }
        selectedImageView = imageView
        let navController = UINavigationController(rootViewController: photoSelector)
        present(navController, animated: true, completion: nil)
    }
    
    fileprivate func getUserImages() {
        guard let uid = currentUser.uid else { return }
        DatabaseLayer.shared.getUserImages(uid: uid) { (values, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            guard let key = values?.first?.key, let tag = Int(key) else { return }
            guard let url = values?.first?.value else { return }
            self.imageArray[tag].loadImage(urlString: url)
        }
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
        guard let image = selectedImageView.image else { return }
        if !(image == #imageLiteral(resourceName: "AddImage")) {
            DatabaseLayer.shared.saveUserDatingImage(image: image)
        } else { return }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))

        view.backgroundColor = offBlack
        setupImageViews()
        
        getUserImages()
        getUserBio()
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

