//
//  SignUpViewController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/3/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit
import Firebase

var currentUser = MyUser()
var selectedImageView = UIImageView()
class SignUpViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 10
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.image = #imageLiteral(resourceName: "AddImage")
        return iv
    }()
    
    let nameTextField = RoundedTextField(color: .white, font: UIFont(name: "Avenir Next", size: 14), cornerRadius: 10, placeHolder: "Name")
    let emailTextField = RoundedTextField(color: .white, font: UIFont(name: "Avenir Next", size: 14), cornerRadius: 10, placeHolder: "Email")
    let passwordTextField = RoundedTextField(color: .white, font: UIFont(name: "Avenir Next", size: 14), cornerRadius: 10, placeHolder: "Password")
    let confirmPasswordTextField = RoundedTextField(color: .white, font: UIFont(name: "Avenir Next", size: 14), cornerRadius: 10, placeHolder: "Confirm")
    let signupButton = LoginButton(color: .orange, textColor: .orange, title: "Sign Up", font: UIFont(name: "Avenir Next", size: 14), cornerRadius: 10)
    let loginButton = LoginButton(color: .lightGray, textColor: .lightGray, title: "Login", font: UIFont(name: "Avenir Next", size: 14), cornerRadius: 10)
    
    let genderTextField = RoundedTextField(color: .white, font: UIFont(name: "Avenir Next", size: 14), cornerRadius: 10, placeHolder: "Gender")
    let interestedInTextField = RoundedTextField(color: .white, font: UIFont(name: "Avenir Next", size: 14), cornerRadius: 10, placeHolder: "Interested In")
    
    let birthdayTextField = RoundedTextField(color: .white, font: UIFont(name: "Avenir Next", size: 14), cornerRadius: 10, placeHolder: "Birthday")

    
    fileprivate func setupViews() {
        view.backgroundColor = .black
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, right: nil, bottom: nil, paddingTop: 40, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 100, height: 100)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddImage)))
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
        setupTextFields()
        
        view.addSubview(signupButton)
        signupButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        signupButton.anchor(top: birthdayTextField.bottomAnchor, left: nil, right: birthdayTextField.rightAnchor, bottom: nil, paddingTop: 20, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 75, height: 40)
        
        view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginButton.anchor(top: signupButton.topAnchor, left: birthdayTextField.leftAnchor, right: nil, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 75, height: 40)
        
    }
    
    @objc fileprivate func handleAddImage(gesture: UITapGestureRecognizer) {
        let photoSelector = PhotoSelectorController(collectionViewLayout: UICollectionViewFlowLayout())
        guard let imageView = gesture.view as? UIImageView else { return }
        selectedImageView = imageView
        let navController = UINavigationController(rootViewController: photoSelector)
        present(navController, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleSignUp() {
   //     guard let profileImage = profileImageView.image else { return }
        guard let name = nameTextField.text, name != "" else { return } //Perhaps check with regex
        guard let email = emailTextField.text, email != "" else { return } //Perhaps check with regex
        guard let password = passwordTextField.text, password != "", let confirmedPassword = confirmPasswordTextField.text, confirmedPassword != "", confirmedPassword == password else {
            return
        }
        
        AuthLayer.shared.createUser(email: email, password: password, name: name, image: profileImageView.image!, gender: genderTextField.text?.lowercased() ?? "", interested: interestedInTextField.text?.lowercased() ?? "", birthday: birthdayTextField.text?.lowercased() ?? "") { (success) in
            if success {
                guard let mainPaginationController = UIApplication.shared.keyWindow?.rootViewController as? MainPagationController else { return }
                mainPaginationController.setupControllersForPage()
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Unable to save user")
            }
        }
    }
    
    @objc fileprivate func handleLogin() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    fileprivate func setupTextFields() {
        let stackView = UIStackView(arrangedSubviews: [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField, genderTextField, interestedInTextField, birthdayTextField])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        view.addSubview(stackView)
        stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 20, paddingLeft: 12, paddingRight: 12, paddingBottom: 0, width: 0, height: 200)
    }
    
    override func viewWillAppear(_ animated: Bool) {
  //      guard let image = selectedImage else { return }
  //      self.profileImageView.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
