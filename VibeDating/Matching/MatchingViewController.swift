//
//  MatchingViewController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/4/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

var firstAutoIdIndex: String?

class MatchingViewController: UIViewController {
    
    var cellId = "cell"
    var cards = [RoundImageView]()
    
    var colors = [UIColor]() 
    
    let profileImageView = RoundImageView(color: .clear, cornerRadius: 50)
    fileprivate func setupViews() {
        view.backgroundColor = offerBlack
        view.addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: nil, right: nil, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 100, height: 100)
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddPulse)))
        guard let url = currentUser.profileImageUrl else { return }
        profileImageView.loadImage(urlString: url)
        profileImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    @objc fileprivate func handleAddPulse(gesture: UITapGestureRecognizer) {
        let pulse = Pulsing(numberOfPulses: 1, radius: 150, position: self.view.center)
        pulse.animationDuration = 0.8
        pulse.backgroundColor = UIColor.lightGray.cgColor
        
        self.view.layer.insertSublayer(pulse, below: profileImageView.layer)
        self.profileImageView.isUserInteractionEnabled = false
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
            self.getMatchesData()
        }
    }

    var cardTimer: Timer?
    fileprivate func getMatchesData() {
        
        DatabaseLayer.shared.getUsersToMatchData { (user, indexUid, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            if let user = user {
                self.createDynamicImageViewsForMatches(user: user)
            }
            
            self.cardTimer?.invalidate()
            self.cardTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (_) in
                if self.cards.count < 4 {
                    guard let indexuid = firstAutoIdIndex else { return }
                    DatabaseLayer.shared.fetchMoreUsersForLoading(indexUid: indexuid, fetchAmount: 15, completion: { (user, indexUid, error) in
                        if let err = error {
                            print(err.localizedDescription)
                            return
                        }
                        
                        if let user = user {
                            self.createDynamicImageViewsForMatches(user: user)
                        }
                    })
                }
                self.profileImageView.isUserInteractionEnabled = true
            })
        }
    }
    
    fileprivate func setupProfileImageObserver() {
        DatabaseLayer.shared.setProfileImageObserver { (downloadUrl, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            guard let url = downloadUrl else { return }
            self.profileImageView.loadImage(urlString: url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getMatchesData()
        setupProfileImageObserver()
    }
    
    
    func createDynamicImageViewsForMatches(user: MyUser) {
        let nameAgeLabel: UILabel = {
            let lbl = UILabel()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM DD, YYYY"
            let interval = formatter.date(from: user.age!)
            let age = Int(floor((Date().timeIntervalSince1970 - (interval?.timeIntervalSince1970)!)/(60 * 60 * 24 * 365)))
            
            let attributedText = NSMutableAttributedString(string: "\(user.name!),", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 24), NSAttributedStringKey.foregroundColor : UIColor.white])
            attributedText.append(NSAttributedString(string: "\(age)", attributes:[NSAttributedStringKey.font : UIFont.systemFont(ofSize: 24), NSAttributedStringKey.foregroundColor : UIColor.white]))
            
            lbl.attributedText = attributedText
            lbl.backgroundColor = .clear
            lbl.layer.shadowColor = UIColor.black.cgColor
            lbl.layer.shadowRadius = 2.0
            lbl.layer.shadowOpacity = 0.7
            lbl.layer.shadowOffset = CGSize(width: 0, height: 0)
            lbl.layer.masksToBounds = false
            return lbl
        }()
        
        let imageView = RoundImageView(color: .clear, cornerRadius: 10)
        imageView.frame = CGRect(x: 10, y: self.view.frame.midY - self.view.frame.height/2.8, width: self.view.frame.width - 20, height: self.view.frame.height/1.4)
        imageView.contentMode = .scaleAspectFill
        guard let url = user.profileImageUrl else { return }
        imageView.loadImage(urlString: url)
        imageView.addSubview(nameAgeLabel)
        nameAgeLabel.frame = CGRect(x: 8, y: imageView.frame.height - 40, width: imageView.frame.width, height: 30)
        imageView.user = user
        imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleImagePan)))
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
        cards.append(imageView)
        print("\(cards.count - 1) : \(user.name ?? "")")
        view.addSubview(imageView)
        view.sendSubview(toBack: imageView)
        view.sendSubview(toBack: profileImageView)
    }
    
    let alphaView = UIView()
    
    @objc fileprivate func handleImageTap(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view as? RoundImageView else { return }
        let matchedUserInfoViewController = MatchedUserInfoViewController()
        matchedUserInfoViewController.user = view.user
        self.present(matchedUserInfoViewController, animated: true, completion: nil)
    }
    
    var angle: CGFloat = 0.0
    var yAxisOffset: CGFloat = 0.0
    var centerY: CGFloat = 0.0
    @objc fileprivate func handleImagePan(gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view as? RoundImageView else { return }
        let translation = gesture.translation(in: self.view)
        let xFromCenter = view.center.x - self.view.center.x
        
        alphaView.frame = view.layer.bounds
        view.addSubview(alphaView)
        
        if xFromCenter < 120 && xFromCenter > -120 {
            self.alphaView.backgroundColor = .clear
        } else if xFromCenter <= -120 {
            self.alphaView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.3)
        } else if xFromCenter >= 120 {
            self.alphaView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.3)
        }
        
        if gesture.state == .began {
            centerY = view.center.y
            if gesture.location(in: self.view).y > self.view.center.y {
                angle = -0.2
                yAxisOffset = -75
            } else {
                angle = 0.2
                yAxisOffset = 75
            }
        }
        
        let divisor = (self.view.frame.width / 2) / angle
        
        if gesture.state == .changed {
            view.center = CGPoint(x: self.view.center.x + translation.x, y: (centerY + translation.y))
            view.transform = CGAffineTransform(rotationAngle: xFromCenter / divisor)
        }
        
        if gesture.state == .ended {
            if xFromCenter <= -120 {
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = CGPoint(x: view.center.x - 200, y: view.center.y + self.yAxisOffset)
                    view.alpha = 0
                }, completion: { (_) in
                    guard let matchUid = view.user.uid else { return }
                    self.postMatchDislikeToFirebase(matchUid: matchUid)
                    view.removeFromSuperview()
                })
                return
            } else if xFromCenter >= 120 {
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = CGPoint(x: view.center.x + 200, y: view.center.y + self.yAxisOffset)
                    view.alpha = 0
                }, completion: { (_) in
                    guard let matchUid = view.user.uid else { return }
                    self.postMatchLikeToFirebase(matchUid: matchUid)
                    view.removeFromSuperview()
                })
                return
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                view.center = CGPoint(x: self.view.center.x, y: self.centerY)
                view.transform = .identity
            })
        }
        
        //HINGE ANIMATION
//        guard let view = gesture.view as? RoundImageView else { return }
//        let centerPointX = view.bounds.midX
//        let centerPointY = view.bounds.origin.y
//
//        let midPoint = self.view.frame.midY - self.view.frame.height/3 - CGFloat((view.tag * 10))
//        let newAnchorPoint = CGPoint(x: centerPointX / view.bounds.width, y: centerPointY / view.bounds.height)
//
//        view.layer.anchorPoint = newAnchorPoint
//
//        let angle = -(gesture.translation(in: self.view).x * .pi / 360)
//        alphaView.frame = view.layer.bounds
//        view.addSubview(alphaView)
//
//        if angle > 0.8 {
//            alphaView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.3)
//        } else if angle < -0.8 {
//            alphaView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.3)
//        } else {
//            view.transform = CGAffineTransform(rotationAngle: angle)
//            view.layer.position = CGPoint(x: self.view.frame.midX, y: midPoint)
//            alphaView.removeFromSuperview()
//        }
//
//        if gesture.state == .ended {
//            if angle > 0.8 {
//                postMatchDislikeToFirebase(tag: view.tag)
//                UIView.animate(withDuration: 0.2, animations: {
//                    view.transform = CGAffineTransform(rotationAngle: 1.5)
//                    view.layer.position = CGPoint(x: self.view.frame.midX, y: midPoint)
//                }, completion: { (_) in
//                    view.removeFromSuperview()
//                })
//            } else if angle < -0.8 {
//                postMatchLikeToFirebase(tag: view.tag)
//                UIView.animate(withDuration: 0.2, animations: {
//                    view.transform = CGAffineTransform(rotationAngle: -1.5)
//                    view.layer.position = CGPoint(x: self.view.frame.midX, y: midPoint)
//                }, completion: { (_) in
//                    view.removeFromSuperview()
//                })
//            } else {
//                UIView.animate(withDuration: 0.3, animations: {
//                    view.layer.transform = CATransform3DIdentity
//                })
//                alphaView.removeFromSuperview()
//            }
//        }
    }
    
    let currentUserImage = RoundImageView(color: offBlack, cornerRadius: 45)
    let matchUserImage = RoundImageView(color: offBlack, cornerRadius: 45)
    
    @objc func handleDismissInterestView(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
//        var size: CGFloat = 90
//        self.currentUserImage.frame = CGRect(x: view.center.x - 2 * size, y: view.center.y - size/2, width: size, height: size)
//        self.matchUserImage.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: size, height: size)
        self.currentUserImage.removeFromSuperview()
        self.matchUserImage.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: {
            view.frame = CGRect(x: view.center.x, y: view.center.y, width: 1, height: 1)
        //    size = 1
        }) { (_) in
            view.removeFromSuperview()
        }
    }
    
    fileprivate func setupMatchView(matchedUser: MyUser) {
        let interestView: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            view.alpha = 0.3
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissInterestView)))
            return view
        }()
        
        interestView.frame = CGRect(x: view.center.x, y: view.center.y, width: 1, height: 1)
        view.addSubview(interestView)

        guard let currentUserUrl = currentUser.profileImageUrl else { return }
        guard let matchUserUrl = matchedUser.profileImageUrl else { return }
        
        currentUserImage.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        interestView.addSubview(currentUserImage)
        currentUserImage.loadImage(urlString: currentUserUrl)
        
        matchUserImage.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        interestView.addSubview(matchUserImage)
        matchUserImage.loadImage(urlString: matchUserUrl)
        
        var size: CGFloat = 0.0
        UIView.animate(withDuration: 0.3) {
            interestView.frame = self.view.frame
            size = 90
            self.currentUserImage.frame = CGRect(x: interestView.center.x - 2 * size, y: interestView.center.y - size/2, width: size, height: size)
            self.matchUserImage.frame = CGRect(x: interestView.center.x + size, y: interestView.center.y - size/2, width: size, height: size)
            interestView.alpha = 1
        }
    }

    fileprivate func postMatchLikeToFirebase(matchUid: String) {
        cards.remove(at: 0)
        
        if cards.count == 3 {
            guard let indexUid = firstAutoIdIndex else { return }
            DatabaseLayer.shared.fetchMoreUsersForLoading(indexUid: indexUid, fetchAmount: 13, completion: { (user, _, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }

                guard let user = user else { return }
                self.createDynamicImageViewsForMatches(user: user)
            })
        }
        
        DatabaseLayer.shared.saveUserLikeData(matchUid: matchUid) { (user, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            guard let user = user else { return }
            self.setupMatchView(matchedUser: user)
        }
    }
    
    fileprivate func postMatchDislikeToFirebase(matchUid: String) {
        cards.remove(at: 0)
        
        if cards.count == 3 {
            guard let indexUid = firstAutoIdIndex else { return }
            DatabaseLayer.shared.fetchMoreUsersForLoading(indexUid: indexUid, fetchAmount: 13, completion: { (user, _, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                
                guard let user = user else { return }
                self.createDynamicImageViewsForMatches(user: user)
            })
        }
        
        DatabaseLayer.shared.saveUserDislikeData(matchUid: matchUid)
    }
}


