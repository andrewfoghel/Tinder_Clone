//
//  UserProfileViewController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/4/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

let offBlack = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
let offerBlack = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1)

class UserProfileViewController: UIViewController {
   
    let btn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(handleOpenSettings), for: .touchUpInside)
        return btn
    }()
    
    @objc fileprivate func handleOpenSettings() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logout = UIAlertAction(title: "Logout", style: .default) { (_) in
            AuthLayer.shared.handleLogout {
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
            }
        }
        let settings = UIAlertAction(title: "Settings" , style: .default) { (_) in
            print("settings")
        }
        let editInfo = UIAlertAction(title: "Edit Info", style: .default) { (_) in
            let editUserInfoVC = EditUserInfoViewController()
            let navController = UINavigationController(rootViewController: editUserInfoVC)
            self.present(navController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(logout)
        alert.addAction(settings)
        alert.addAction(editInfo)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(btn)
        btn.anchor(top: view.topAnchor, left: view.leftAnchor, right: nil, bottom: nil, paddingTop: 100, paddingLeft: 100, paddingRight: 0, paddingBottom: 0, width: 100, height: 100)
        
        view.backgroundColor = .blue
    }
    
    
    
}
