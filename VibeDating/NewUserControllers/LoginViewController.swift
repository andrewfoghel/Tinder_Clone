//
//  LoginViewController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/3/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate

class LoginViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let mainLogoLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "V"
        lbl.font = UIFont(name: "Marker Felt", size: 130)
        lbl.textColor = .white
        return lbl
    }()
    
    let secondaryLogoLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "ibe"
        lbl.font = UIFont(name: "Marker Felt", size: 36)
        lbl.textColor = .lightGray
        return lbl
    }()
    
    fileprivate func setupLogoView() {
        view.addSubview(mainLogoLabel)
        mainLogoLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.centerXAnchor, right: nil, bottom: nil, paddingTop: 40, paddingLeft: -35.5, paddingRight: 0, paddingBottom: 0, width: 75, height: 105)
        view.addSubview(secondaryLogoLabel)
        secondaryLogoLabel.anchor(top: nil, left: mainLogoLabel.rightAnchor, right: nil, bottom: mainLogoLabel.bottomAnchor, paddingTop: 0, paddingLeft: -24, paddingRight: 0, paddingBottom: 0, width: 0, height: 40)
    }

    let emailTextField = LoginTextField()
    let passwordTextField = LoginTextField()
    
    let loginButton = LoginButton(color: offBlack, textColor: offerBlack, title: "Login", font: UIFont(name: "Marker Felt", size: 16), cornerRadius: 10)
    let signupButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .clear
        let attributedString = NSMutableAttributedString(string: "Don't have an account? Sign up", attributes: [NSAttributedStringKey.font : UIFont(name: "Marker Felt", size: 14) ?? UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor : UIColor.white])
        btn.setAttributedTitle(attributedString, for: .normal)
        btn.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return btn
    }()
    
    var stackview = UIStackView()
    var stackviewBottomConstraint = NSLayoutConstraint()
    fileprivate func setupViews() {
        emailTextField.placeHolderLabel.text = "Email"
        emailTextField.textField.delegate = self //
        emailTextField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)////
        
        passwordTextField.placeHolderLabel.text = "Password"
        passwordTextField.textField.isSecureTextEntry = true
        passwordTextField.textField.delegate = self //
        passwordTextField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)///
        
        stackview = UIStackView(arrangedSubviews: [emailTextField, passwordTextField])
        view.addSubview(stackview)
        stackview.axis = .vertical
        stackview.distribution = .fillEqually
        let estimatedWidth = (self.view.frame.width) - 40
        stackview.anchor(top: nil, left: nil, right: nil, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: estimatedWidth, height: CGFloat(stackview.arrangedSubviews.count * (8 + 36))) // GET RID OF /2
        stackview.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true //SET CENTER X
        stackviewBottomConstraint = stackview.bottomAnchor.constraint(equalTo: self.view.centerYAnchor, constant: CGFloat(-stackview.arrangedSubviews.count * (8 + 36)) / 2)
        stackviewBottomConstraint.isActive = true
        
        setupLogoView()
        setupAuthButtons()
        
    }
    
    //AUTH VIDEO 5
    fileprivate func setupAuthButtons() {
        view.addSubview(loginButton)
        loginButton.anchor(top: passwordTextField.bottomAnchor, left: passwordTextField.leftAnchor, right: passwordTextField.rightAnchor, bottom: nil, paddingTop: 12, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 40)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginButton.isUserInteractionEnabled = false
        
        view.addSubview(signupButton)
        signupButton.anchor(top: loginButton.bottomAnchor, left: loginButton.leftAnchor, right: loginButton.rightAnchor, bottom: nil, paddingTop: 8, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 30)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = offerBlack
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboard)))
        setupViews()
    }
    
    @objc fileprivate func handleDismissKeyboard(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc fileprivate func handleSignup() {
        let signupVC = SignUpViewController()
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
    
    @objc fileprivate func handleLogin() {
        print("login")
        
        if checkValidationOfInputFields() {
            guard let email = emailTextField.textField.text else { return }
            guard let password = passwordTextField.textField.text else { return }
            AuthLayer.shared.handleLogin(email: email, password: password, completion: { (user, error) in
                if let err = error {
                    appDelegate.errorView(message: err.localizedDescription, color: .red)
                    return
                }
                
                guard let user = user else { appDelegate.errorView(message: "Couldn't find user, you may have to create a new account", color: .red); return }
                currentUser = user
                guard let mainPaginationController = UIApplication.shared.keyWindow?.rootViewController as? MainPagationController else { return }
                mainPaginationController.setupControllersForPage()
                self.dismiss(animated: true, completion: nil)

            })
        } else {
            appDelegate.errorView(message: "Please fill in all the required information", color: .red)
        }
    }
    
    // AUTH VIDEO 6
    fileprivate func changeLoginButton() {
        if checkValidationOfInputFields() {
            self.loginButton.backgroundColor = .lightGray
            self.loginButton.isUserInteractionEnabled = true
        } else {
            self.loginButton.backgroundColor = offBlack
            self.loginButton.isUserInteractionEnabled = false
        }
    }
    
    // AUTH VIDEO 6
    fileprivate func checkValidationOfInputFields() -> Bool{
        var count = 0
        for view in stackview.subviews {
            guard let inputView = view as? LoginTextField, inputView.textField.text != "" else { continue }
            count += 1
        }
        
        if count == stackview.subviews.count {
            return true
        } else {
            return false
        }
    }
    
}

// AUTH VIDEO 6
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let loginTextField = textField.superview as? LoginTextField else { return }
        loginTextField.placeHolderLeftOrRightAnchor.isActive = false
        loginTextField.placeHolderLeftOrRightAnchor = loginTextField.placeHolderLabel.rightAnchor.constraint(equalTo: loginTextField.underlineView.rightAnchor, constant: -2)
        loginTextField.placeHolderLeftOrRightAnchor.isActive = true
        
        UIView.animate(withDuration: 0.3, animations: {
            loginTextField.layoutIfNeeded()
            loginTextField.placeHolderLabel.alpha = 1
            loginTextField.placeHolderLabel.textAlignment = .right
        }) { (_) in }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let loginTextField = textField.superview as? LoginTextField else { return }
        if textField.text == "" {
            loginTextField.placeHolderLeftOrRightAnchor.isActive = false
            loginTextField.placeHolderLeftOrRightAnchor = loginTextField.placeHolderLabel.leftAnchor.constraint(equalTo: loginTextField.underlineView.leftAnchor, constant: -2)
            loginTextField.placeHolderLeftOrRightAnchor.isActive = true
            
            UIView.animate(withDuration: 0.3, animations: {
                loginTextField.layoutIfNeeded()
                loginTextField.placeHolderLabel.alpha = 0.5
                loginTextField.placeHolderLabel.textAlignment = .left
            }) { (_) in }
        }
        changeLoginButton()
    }
    
    @objc func textFieldDidChange(_ textfield: UITextField) {
        changeLoginButton()
    }
}



