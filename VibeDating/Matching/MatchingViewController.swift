//
//  MatchingViewController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/4/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

class MatchingViewController: UIViewController {
    
    var cellId = "cell"
    var cards = [RoundImageView]()
    
    var colors = [UIColor]()
    
    fileprivate func setupViews() {
        
    }
    
    var cardTimer: Timer?
    fileprivate func getMatchesData() {
        
        DatabaseLayer.shared.getUsersToMatchData { (user, indexUid, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            var creation = 0.0
            if let user = user {
                self.createDynamicImageViewsForMatches(user: user)
            }
            
            self.cardTimer?.invalidate()
            self.cardTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (_) in
                if self.cards.count < 4 {
                    guard let indexUid = indexUid else { return }
                    DatabaseLayer.shared.fetchMoreUsersForLoading(indexUid: indexUid, fetchAmount: 15, completion: { (user, indexUid, error) in
                        if let err = error {
                            print(err.localizedDescription)
                            return
                        }
                        
                        if let user = user {
                            self.createDynamicImageViewsForMatches(user: user)
                        }
                        
                    })
                }
            })
        }
    }

//        DatabaseLayer.shared.getUsersToMatchData { (user, indexUid, error)  in
//            if let err = error {
//                print(err.localizedDescription)
//                return
//            }
//
//            if let user = user {
//                self.createDynamicImageViewsForMatches(user: user)
//            }
//
//            self.cardTimer?.invalidate()
//            self.cardTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (_) in
//                if self.cards.count < 4 {
//                    guard let indexUid = user?.autoIdIndex else { return }
//                    DatabaseLayer.shared.fetchMoreUsersForLoading(indexUid: indexUid, fetchAmount: 5, completion: { (user, error) in
//                        if let err = error {
//                            print(err.localizedDescription)
//                            return
//                        }
//                        if let user = user {
//                            self.createDynamicImageViewsForMatches(user: user)
//                        }
//                    })
//                }
//            })
//        }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        setupViews()
        getMatchesData()
        
    }
    
    func createDynamicImageViewsForMatches(user: MyUser) {
            let imageView = RoundImageView(color: .clear, cornerRadius: 10)
            imageView.frame = CGRect(x: 10, y: self.view.frame.midY - self.view.frame.height/2.8, width: self.view.frame.width - 20, height: self.view.frame.height/1.4)
            imageView.contentMode = .scaleAspectFill
            guard let url = user.profileImageUrl else { return }
            imageView.loadImage(urlString: url)
            imageView.user = user
            imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleImagePan)))
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
            cards.append(imageView)
            print("\(cards.count - 1) : \(user.name)")
            view.addSubview(imageView)
            view.sendSubview(toBack: imageView)
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
        var size: CGFloat = 90
//        self.currentUserImage.frame = CGRect(x: view.center.x - 2 * size, y: view.center.y - size/2, width: size, height: size)
//        self.matchUserImage.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: size, height: size)
        self.currentUserImage.removeFromSuperview()
        self.matchUserImage.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: {
            view.frame = CGRect(x: view.center.x, y: view.center.y, width: 1, height: 1)
            size = 1
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
            guard let indexUid = cards[0].user.autoIdIndex else { return }
            DatabaseLayer.shared.fetchMoreUsersForLoading(indexUid: indexUid, fetchAmount: 13, completion: { (user, _, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }

                guard let user = user else { return }
                self.createDynamicImageViewsForMatches(user: user)
            })
        }
      //  guard let indexUid = users[self.users.count - 1].uid else { return }
//       if tag == 3 {
//            var tag = 0
//            DatabaseLayer.shared.fetchMoreUsersForLoading(indexUid: indexUid, completion: { (user, error) in
//                if let err = error {
//                    print(err.localizedDescription)
//                    return
//                }
//
//                guard let user = user else { return }
//                self.users.append(user)
//                print("\(tag) : \(user.name) : \(user.uid)")
//                self.createDynamicImageViewsForMatches(user: user, tag: tag)
//                tag += 1
//            })
    //    }
        
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
            guard let indexUid = cards[0].user.autoIdIndex else { return }
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


