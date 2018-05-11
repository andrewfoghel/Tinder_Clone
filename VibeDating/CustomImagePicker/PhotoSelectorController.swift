//
//  PhotoSelectorController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/4/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate {
    let cellId = "cellId"
    let headerId = "headerId"
    
    var editUserInfoViewController: EditUserInfoViewController?
    var signUpViewController: SignUpViewController?
    
    let customAnimationPresenter = CustomAnimationPresenter()
    let customAnimationDismisser = CustomAnimationDismisser()

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if editUserInfoViewController != nil {
            return customAnimationPresenter
        } else {
            return customAnimationDismisser
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if editUserInfoViewController != nil {
            return customAnimationDismisser
        } else {
            return customAnimationPresenter
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        view.backgroundColor = offerBlack
        collectionView?.backgroundColor = offerBlack
        collectionView?.register(ImageViewCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        setupNavigationButtons()
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                   self.fetchPhotos()
                } else {
                    //Some alert controller perhaps
                }
            })
        } else {
            self.fetchPhotos()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
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
    
    let saveButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Save", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return btn
    }()
    
    let cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return btn
    }()
    
    fileprivate func setupNavigationButtons() {
        view.addSubview(fillerView)
        fillerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
        
        view.addSubview(navBar)
        navBar.anchor(top: fillerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 44)
        
        navBar.addSubview(saveButton)
        saveButton.anchor(top: nil, left: nil, right: view.rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 10, paddingBottom: 0, width: 50, height: 20)
        saveButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor).isActive = true
        
        navBar.addSubview(cancelButton)
        cancelButton.anchor(top: nil, left: view.leftAnchor, right: nil, bottom: nil, paddingTop: 0, paddingLeft: 10, paddingRight: 0, paddingBottom: 0, width: 60, height: 20)
        cancelButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor).isActive = true
 
//        navigationController?.navigationBar.tintColor = .white
//        navigationController?.navigationBar.barTintColor = .black
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSave() {
        
        guard let image = header?.photoImageView.image else { return }
        
        if let editVC = self.editUserInfoViewController {
            if editVC.isBeingReplaced {
                guard let userImage = editVC.cellToManipulate.userImage else { return }
                DatabaseLayer.shared.updateUserImage(imageIndexId: userImage.id, image: image, isProfileImage: editVC.isProfileImage, completion: { (downloadUrl, error) in
                    if let err = error {
                        print(err.localizedDescription)
                        return
                    }
                    
                   
                    editVC.mainImageView.image = image
                    guard let url = downloadUrl else { return }
//                    editVC.cellToManipulate.imageView.loadImage(urlString: url)
                    editVC.imageUrls[editVC.index].url = url
//                    editVC.cellToManipulate.userImage?.url = url
                    editVC.cells.removeAll()
                    editVC.collectionView.isUserInteractionEnabled = false
                    editVC.collectionView.setContentOffset(.zero, animated: true)
                    editVC.collectionView.isUserInteractionEnabled = true
              //      editVC.cells.removeAll()
                    editVC.collectionView.reloadData()
                })
//                editVC.cellToManipulate.imageView.image = image
//                editVC.mainImageView.image = image
//                editVC.imageUrls[editVC.index].url =
            } else {
                DatabaseLayer.shared.saveUserDatingImage(image: image, completion: { (userImage, error) in
                    if let err = error {
                        print(err.localizedDescription)
                        return
                    }
                    
                    guard let img = userImage else { return }
                    editVC.imageUrls.append(img)
                    editVC.cells.removeAll()
                    editVC.collectionView.isUserInteractionEnabled = false
                    editVC.collectionView.setContentOffset(.zero, animated: true)
                    editVC.collectionView.isUserInteractionEnabled = true
                    editVC.collectionView.reloadData()
                    
                })
            }
        } else if let signUpVC = signUpViewController {
            signUpVC.profileImageView.image = image
            signUpViewController = nil
        }
        
        
        
     //   DatabaseLayer.shared.saveUserDatingImage(image: image)

   //     selectedImageView.image = header?.photoImageView.image
        self.dismiss(animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageViewCollectionViewCell
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 3)/4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    var header: PhotoSelectorHeader?
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        
        self.header = header
        
        if let selectedImage = selectedImage {
            if let index = self.images.index(of: selectedImage) {
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 450, height: 450)
                imageManager.requestImage(for: assets[index], targetSize: targetSize, contentMode: .default, options: nil, resultHandler: { (image, info) in
                    if let image = image {
                        header.photoImageView.image = image
                    }
                })
            }
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.row]
        self.collectionView?.reloadData()
        let indexpath = IndexPath(item: 0, section: 0)
        
        collectionView.scrollToItem(at: indexpath, at: .bottom, animated: true)
    }
    
    var images = [UIImage]()
    var selectedImage: UIImage?
    
    var assets = [PHAsset]()
    
    fileprivate func assetFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 75
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    fileprivate func fetchPhotos() {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetFetchOptions())
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetsize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetsize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                })
            }
        }
    }
    
}

