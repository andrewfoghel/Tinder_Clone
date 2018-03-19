//
//  LoginViewController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/3/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let emailTextField = RoundedTextField(color: .white, font: UIFont(name: "Avenir Next", size: 14), cornerRadius: 10, placeHolder: "Email")
    let passwordTextField = RoundedTextField(color: .white, font: UIFont(name: "Avenir Next", size: 14), cornerRadius: 10, placeHolder: "Password")
    
    let signupButton = LoginButton(color: .orange, textColor: .orange, title: "Sign Up", font: UIFont(name: "Avenir Next", size: 14), cornerRadius: 10)
    
    let loginButton = LoginButton(color: .lightGray, textColor: .lightGray, title: "Login", font: UIFont(name: "Avenir Next", size: 14), cornerRadius: 10)
    
    
    fileprivate func setupViews() {
        view.addSubview(emailTextField)
        emailTextField.anchor(top: nil, left: nil, right: nil, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 250, height: 30)
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40).isActive = true
        
        view.addSubview(passwordTextField)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.anchor(top: nil, left: nil, right: nil, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 250, height: 30)
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive = true
        
        view.addSubview(signupButton)
        signupButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        signupButton.anchor(top: passwordTextField.bottomAnchor, left: nil, right: passwordTextField.rightAnchor, bottom: nil, paddingTop: 20, paddingLeft: 0, paddingRight: -12, paddingBottom: 0, width: 75, height: 40)
        
        view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginButton.anchor(top: signupButton.topAnchor, left: passwordTextField.leftAnchor, right: nil, bottom: nil, paddingTop: 0, paddingLeft: -12, paddingRight: 0, paddingBottom: 0, width: 75, height: 40)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .black
        setupViews()

        handleLogin()
    }
    
    @objc fileprivate func handleSignup() {
        let signupVC = SignUpViewController()
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
    
    @objc fileprivate func handleLogin() {
        guard let email = emailTextField.text, email != "" else { return }
        guard let password = passwordTextField.text, password != "" else { return }

        AuthLayer.shared.handleLogin(email: email, password: password) { (user, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            guard let user = user else { return }
            currentUser = user
            guard let mainPaginationController = UIApplication.shared.keyWindow?.rootViewController as? MainPagationController else { return }
            mainPaginationController.setupControllersForPage()
            self.dismiss(animated: true, completion: nil)
        }
    }
}





