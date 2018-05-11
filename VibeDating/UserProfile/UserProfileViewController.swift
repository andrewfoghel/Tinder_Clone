//
//  UserProfileViewController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/4/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

// CUSTOM COLORS THAT I USE ALL OVER THE PLACE
let offBlack = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1) //DARKER BLACK
let offerBlack = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1) //MAIN BACKGROUND COLOR

class UserProfileViewController: UIViewController {
   
    @objc fileprivate func handleOpenSettings() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logout = UIAlertAction(title: "Logout", style: .default) { (_) in
            AuthLayer.shared.handleLogout {
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
            }
        }
        let editAge = UIAlertAction(title: "Edit Age" , style: .default) { (_) in
            print("editage")
        }
        let editInterest = UIAlertAction(title: "Edit Interests", style: .default) { (_) in
            print("edit interest")
        }
        let editLocationPref = UIAlertAction(title: "Edit Distance", style: .default) { (_) in
            print("edit Distance")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(cancel)
        alert.addAction(logout)
        alert.addAction(editAge)
        alert.addAction(editInterest)
        alert.addAction(editLocationPref)

        self.present(alert, animated: true, completion: nil)
    }
    // 1 --- TEMP WAY TO SET UP USER FUNC SEGUES *****************************************

    // 2 --- CREATING VIEWS FOR PROFILE PAGE *****************************************
    lazy var profileImageView = RoundImageView(color: .clear, cornerRadius: (self.view.frame.width/2.145)/2) //SIZING FOR ALL PHONES
    
    let nameAgeLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        return lbl
    }()
    
    let jobTextField: UITextField = {
        let tf = UITextField()
        tf.isEnabled = false
        tf.isUserInteractionEnabled = false
        tf.textColor = .white
        tf.text = currentUser.job!
        tf.textAlignment = .center
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.leftViewMode = .always
        return tf
    }()
    
    let leftTextFieldImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "job"))
        return iv
    }()
    
    let optionsButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .gray
        btn.setImage(#imageLiteral(resourceName: "settings").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleOpenSettings), for: .touchUpInside)
        return btn
    }()
    
    let editInfoButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .gray
        btn.setImage(#imageLiteral(resourceName: "edit").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleEditInfo), for: .touchUpInside)
        return btn
    }()
    
    // 2 --- CREATING VIEWS FOR PROFILE PAGE *****************************************
    
    
    // 2.5 --- EDIT INFO/SETTINGS/PROFILE PIC TARGETS/GESTURES *****************************************
    @objc fileprivate func handleEditInfo() {
        let editUserInfoVC = EditUserInfoViewController()
    //    let navController = UINavigationController(rootViewController: editUserInfoVC)
        self.present(editUserInfoVC, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleOpenUserProfile(gesture: UITapGestureRecognizer) {
        let matchedUserInfoViewController = MatchedUserInfoViewController()
        matchedUserInfoViewController.user = currentUser
        self.present(matchedUserInfoViewController, animated: true, completion: nil)
    }
    
    // 2.5 --- EDIT INFO AND SETTINGS TARGETS *****************************************

    
    // 2.1 --- NSATTRIBUTED STR FOR NAME AGE *****************************************
    fileprivate func setNameAgeText(name: String, age: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(name),", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: view.frame.width/12.5), NSAttributedStringKey.foregroundColor : UIColor.white])
        attributedText.append(NSAttributedString(string: age, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: view.frame.width/12.5), NSAttributedStringKey.foregroundColor : UIColor.white]))
        return attributedText
    }
    // 2.1 --- NSATTRIBUTED STR FOR NAME AGE *****************************************

    // 2.2 --- STACKVIEW FOR MAJOR LABEL *****************************************
        //2.2.1 --- SPACER VIEWS FOR STACK VIEW *****************************************
    let leftSpaceView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let rightSpaceView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
        //2.2.1 --- SPACER VIEWS FOR STACK VIEW *****************************************
            //THIS WILL MAKE THAT IMAGE AND LABEL TO STAYED CENTERED ALL THE TIME NICELY AND SOMEWHAT EFFORTLESSLY. (IT WILL LOOK GOOD ON ALL SCREENS)
    fileprivate func setupMajorLabelStackView() {
        let stackView = UIStackView(arrangedSubviews: [leftSpaceView, jobTextField, rightSpaceView]) //INIT STACKVIEW
        stackView.axis = .horizontal //SET AXIS (WHICH WAY IT WILL GO)
        stackView.distribution = .fill //SET FILL TYPE, FILL BECAUSE TEXT IS CONSTANTLY CHANGING
        stackView.spacing = 10 // SOME SPACING
        view.addSubview(stackView)
        jobTextField.sizeToFit() //SIZE TEXT FIELD TO FULL SIZE
        jobTextField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true //CENTER IN VIEW (STACK VIEW AS WELL)
        
        // GET WIDTH CONSTRAINTS FOR SPACERVIEWS
        let leftSpacerViewWidthConstraint = leftSpaceView.widthAnchor.constraint(lessThanOrEqualToConstant: (self.view.frame.width - jobTextField.frame.width)/2)
        let rightSpacerViewWidthConstraint = rightSpaceView.widthAnchor.constraint(lessThanOrEqualToConstant: (self.view.frame.width - jobTextField.frame.width)/2)
        //SET SPACERVIEW WIDTH PROIRITIES TO LESS THAN THAT OF THE TEXTFIELD
        leftSpacerViewWidthConstraint.priority = .init(rawValue: 998)
        rightSpacerViewWidthConstraint.priority = .init(rawValue: 998)
        leftSpacerViewWidthConstraint.isActive = true
        rightSpacerViewWidthConstraint.isActive = true
        
        //ANCHOR STACKVIEW
        stackView.anchor(top: nameAgeLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: self.view.frame.width/40, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 25)
    }
    // 2.2 --- STACKVIEW FOR MAJOR LABEL *****************************************

    // 3 --- SET VIEWS FOR PROFILE PAGE *****************************************
    fileprivate func setupViews() {
        // 2.3 ******* SEE CURVEDCONTAINERVIEW FILE
        let curvedContainerView = CurvedContainerView()
        var factor: CGFloat = 0.0
        if self.view.frame.height > 800 {
            factor = 1.65
        } else {
            factor = 1.5
        }
        
        curvedContainerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/factor)
        curvedContainerView.backgroundColor = offerBlack
        view.addSubview(curvedContainerView)
        // 2.3 *******
        
        view.addSubview(profileImageView)
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleOpenUserProfile)))
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, right: nil, bottom: nil, paddingTop: self.view.frame.height/27, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: self.view.frame.width/2.14, height: self.view.frame.width/2.14)
        profileImageView.layer.cornerRadius = (self.view.frame.width/2.14)/2
        profileImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        guard let url = currentUser.profileImageUrl else { return }
        profileImageView.loadImage(urlString: url)
        
        view.addSubview(nameAgeLabel)
        nameAgeLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: self.view.frame.width/40, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 35)
        guard let name = currentUser.name else { return }
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM DD, YYYY"
        let interval = formatter.date(from: currentUser.age!)
        let age = Int(floor((Date().timeIntervalSince1970 - (interval?.timeIntervalSince1970)!)/(60 * 60 * 24 * 365)))
        
        nameAgeLabel.attributedText = setNameAgeText(name: "\(name)", age: " \(age)")
        
        //2.2 *******
        leftTextFieldImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/9.375, height: self.view.frame.width/13.9)
        jobTextField.leftView = leftTextFieldImageView
        jobTextField.font = UIFont.systemFont(ofSize: self.view.frame.width/18.75)
        setupMajorLabelStackView()
        //2.2 *******
        
        view.addSubview(optionsButton)
        optionsButton.anchor(top: jobTextField.bottomAnchor, left: nil, right: profileImageView.leftAnchor, bottom: nil, paddingTop: self.view.frame.width/9.375, paddingLeft: 0, paddingRight: -self.view.frame.width/10, paddingBottom: 0, width: self.view.frame.width/6.25, height: self.view.frame.width/6.25)
        optionsButton.layer.cornerRadius = (self.view.frame.width/6.25)/2
        
        view.addSubview(editInfoButton)
        editInfoButton.anchor(top: optionsButton.topAnchor, left: profileImageView.rightAnchor, right: nil, bottom: nil, paddingTop: 0, paddingLeft: -self.view.frame.width/10, paddingRight: 0, paddingBottom: 0, width: self.view.frame.width/6.25, height: self.view.frame.width/6.25)
        editInfoButton.layer.cornerRadius = (self.view.frame.width/6.25)/2
        
    }
    // 3 --- SET VIEWS FOR PROFILE PAGE *****************************************


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = offBlack
        // 3 ******
        setupViews()
        // 3 ******

    }
    
    

    
}
