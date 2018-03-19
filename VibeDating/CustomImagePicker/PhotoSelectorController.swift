//
//  PhotoSelectorController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/4/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorController: UIViewController {
    
    var images = [UIImage]()
    var assets = [PHAsset]()
    
    var selectedImage: UIImage?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        return sv
    }()
    
    fileprivate func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleAddImage))
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func handleAddImage() {
        selectedImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
  //  var selectedImageView = RoundImageView(color: .purple, cornerRadius: 10)
    
    fileprivate func setupViews() {
    //    view.addSubview(selectedImageView)
    //    selectedImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, right: nil, bottom: nil, paddingTop: 24, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 350, height: 350)
    //    selectedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(scrollView)
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, right: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 34, paddingLeft: 0, paddingRight: 0, paddingBottom: 24, width: 350, height: 0)
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationButtons()
        setupViews()
        fetchPhotos()
    }
    
    
    var cells = [String : RoundImageView]()
    func setupGrid(size: Int) {
        let step: CGFloat = CGFloat(size / 4)
        DispatchQueue.main.async {
            self.scrollView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePan)))
            self.scrollView.contentSize.height = (step * 80) + (step * 10)
            for i in 0...size - 1 {
                let iv = RoundImageView(color: .clear, cornerRadius: 10)
                let colCount: CGFloat = CGFloat(i % 4)
                let rowCount: CGFloat = CGFloat(i / 4)
                
                iv.frame = CGRect(x: (colCount * 80) + (colCount * 10), y: (rowCount * 80) + (rowCount * 10), width: 80, height: 80)
                self.scrollView.addSubview(iv)
                iv.contentMode = .scaleAspectFill
                iv.image = self.images[i]
                
                let key = "\(Int(rowCount))|\(Int(colCount))"
                self.cells[key] = iv
            }
        }
    }
    
    var selectedCell: RoundImageView?
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: scrollView)
        let width = view.frame.width / 4
        let i = Int(location.x / width)
        let j = Int(location.y / width)
        
        let key = "\(j)|\(i)"
        guard let imageView = cells[key] else { return }
        let cellOriginalFrame = selectedCell?.frame
        if selectedCell != imageView {
//            if selectedCell == cells["0|0"] {
//                selectedCell?.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
//            } else if selectedCell == cells["0|3"] {
//                selectedCell?.frame = CGRect(x: self.scrollView.frame.width - 80, y: 0, width: 80, height: 80)
//            } else if self.selectedCell == self.cells["6|0"] {
//                self.selectedCell?.frame = CGRect(x: 0, y: self.scrollView.frame.height - 90, width: 80, height: 80)
//            } else if self.selectedCell == self.cells["6|3"] {
//                self.selectedCell?.frame = CGRect(x: self.scrollView.frame.width - 80, y: self.scrollView.frame.height - 90, width: 80, height: 80)
//            } else if j == 0 || selectedCell == self.cells["0|\(i)"]{
//                self.selectedCell?.frame = CGRect(x: (self.selectedCell?.frame.origin.x)! + 40, y: 0, width: 80, height: 80)
//            } else {
                selectedCell?.layer.transform = CATransform3DIdentity
                selectedCell?.layer.borderColor = UIColor.clear.cgColor
//            }
        }
        
        selectedCell = imageView
        scrollView.bringSubview(toFront: imageView)
        var size: CGFloat = 80
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//            if j == 0 && i == 0 {
//                imageView.frame = CGRect(x: 0, y: 0, width: 160, height: 160)
//            } else if j == 0 && i == 3 {
//                imageView.frame = CGRect(x: self.scrollView.frame.width - 160, y: 0, width: 160, height: 160)
//            } else if j == 6 && i == 0 {
//                imageView.frame = CGRect(x: 0, y: self.scrollView.frame.height - 170, width: 160, height: 160)
//            } else if j == 6 && i == 3 {
//                imageView.frame = CGRect(x: self.scrollView.frame.width - 170, y: self.scrollView.frame.height - 160, width: 160, height: 160)
//            } else if j == 0 {
//                let centerX: CGFloat = CGFloat((i * 80) + (i * 10) + 40)
//                imageView.frame = CGRect(x: centerX - 80, y: 0, width: 160, height: 160)
//            } else {
                imageView.layer.transform = CATransform3DMakeScale(2, 2, 2)
//            }
        }, completion: nil)
        
        if gesture.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
//                if self.selectedCell == self.cells["0|0"] {
//                    self.selectedCell?.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
//                } else if self.selectedCell == self.cells["0|3"] {
//                    self.selectedCell?.frame = CGRect(x: self.scrollView.frame.width - 80, y: 0, width: 80, height: 80)
//                } else if self.selectedCell == self.cells["6|0"] {
//                    self.selectedCell?.frame = CGRect(x: 0, y: self.scrollView.frame.height - 90, width: 80, height: 80)
//                } else if self.selectedCell == self.cells["6|3"] {
//                    self.selectedCell?.frame = CGRect(x: self.scrollView.frame.width - 80, y: self.scrollView.frame.height - 90, width: 80, height: 80)
//                } else if self.selectedCell == self.cells["0|\(i)"] {
//                    self.selectedCell?.frame = CGRect(x: CGFloat(i * 80) + CGFloat(i * 10), y: 0, width: 80, height: 80)
//                }else {
                self.selectedCell?.layer.borderColor = UIColor.green.cgColor
                self.selectedCell?.layer.borderWidth = 2
                self.selectedCell?.layer.transform = CATransform3DIdentity

//                }
            }, completion: { (_) in
                self.selectedImage = imageView.image
            })
        }
    }
    
    fileprivate func assetFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 28
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
                    }
                })
            }
            self.setupGrid(size: self.images.count)
        }
    }
    
    
    
}

