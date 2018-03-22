//
//  MatchedUserInfo.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/14/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

class MatchedUserInfoViewController: UIViewController {
    let cellId = "cell"
    
    var user: MyUser?
    var images = [String]()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        cv.backgroundColor = offerBlack
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = true
        cv.indicatorStyle = .black
        return cv
    }()
    
    let dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .blue
        btn.layer.masksToBounds = true  
        btn.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return btn
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir Next", size: 16)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir Next", size: 12)
        label.textColor = .white
        return label
    }()
    
    let seperatorInset: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let bioTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont(name: "Avenir Next", size: 14)
        tv.textColor = .white
        tv.isUserInteractionEnabled = false
        tv.backgroundColor = .clear
        return tv
    }()
    
    fileprivate func setupNavigationItems() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    fileprivate func setupViews() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: self.view.frame.height / 2.165)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.view.frame.width - 10, right: 0)
        collectionView.register(ImageViewCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: collectionView.bottomAnchor, left: nil, right: view.rightAnchor, bottom: nil, paddingTop: -20, paddingLeft: 0, paddingRight: 40, paddingBottom: 0, width: 40, height: 40)
        dismissButton.layer.cornerRadius = 20
        
        view.addSubview(nameLabel)
        nameLabel.text = user?.name
        nameLabel.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 8, paddingLeft: 8, paddingRight: 12, paddingBottom: 0, width: 0, height: 20)
        
        view.addSubview(locationLabel)
        locationLabel.text = "Location"
        locationLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, right: nameLabel.rightAnchor, bottom: nil, paddingTop: 4, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 16)
        
        view.addSubview(seperatorInset)
        seperatorInset.anchor(top: locationLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 8, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 1)
        
        view.addSubview(bioTextView)
        bioTextView.anchor(top: seperatorInset.bottomAnchor, left: locationLabel.leftAnchor, right: locationLabel.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 8, paddingLeft: 0, paddingRight: 0, paddingBottom: 8, width: 0, height: 0)
        
    }
    
    @objc fileprivate func handleBack() {
        dismiss(animated: true, completion: nil)
    }
    
    let pagationController: UIPageViewController = {
        let pc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return pc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = offerBlack
        setupNavigationItems()
        setupViews()
        handleFetchUserBio()
        handleFetchUserImages()
    }

    fileprivate func handleFetchUserImages() {
        guard let uid = user?.uid else { return }
        DatabaseLayer.shared.getUserImages(uid: uid) { (dictionaries, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            guard let dictionaries = dictionaries else { return }
            dictionaries.forEach({ (key, value) in
                self.images.append(value)
            })
            
            self.attemptReloadCollectionView()
        }
    }
    
    var timer: Timer?
    fileprivate func attemptReloadCollectionView() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReloadCollectionView), userInfo: nil, repeats: false)
    }
    
    @objc fileprivate func handleReloadCollectionView() {
        collectionView.reloadData()
    }
    
    
    fileprivate func handleFetchUserBio() {
        guard let uid = user?.uid else { return }
        DatabaseLayer.shared.getUserBio(uid: uid) { (bio, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            guard let bio = bio else { return }
            self.bioTextView.text = bio
        }
    }
}

extension MatchedUserInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageViewCollectionViewCell
        let url = images[indexPath.item]
        cell.imageView.loadImage(urlString: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return(CGSize(width: self.view.frame.width, height: self.view.frame.width))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

