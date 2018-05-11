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
        iv.layer.cornerRadius = 90
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.image = #imageLiteral(resourceName: "AddImage")
        return iv
    }()
    
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
    
    //Date Picker Popup
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = offBlack
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        return view
    }()
    
    let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.layer.cornerRadius = 10
        dp.layer.masksToBounds = true
        return dp
    }()
    
    lazy var containerViewCancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .clear
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(handleCancelPopup), for: .touchUpInside)
        return btn
    }()
    
    @objc fileprivate func handleCancelPopup() {
        birthdayTextField.textField.resignFirstResponder()
    }
    
   lazy var containerViewSetDateButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .clear
        btn.setTitle("Set Date", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(handleSetDateFromPopup), for: .touchUpInside)
        return btn
    }()
    
    @objc fileprivate func handleSetDateFromPopup() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        birthdayTextField.textField.text = dateFormatter.string(from: datePicker.date)
        birthdayTextField.textField.resignFirstResponder()
    }
    
    fileprivate func setupDatePickerPopup() {
        view.addSubview(containerView)
        containerView.addSubview(datePicker)
        containerView.addSubview(containerViewCancelButton)
        containerView.addSubview(containerViewSetDateButton)
        
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.setValue(false, forKey: "highlightsToday")
        
        containerView.frame = CGRect(x: view.center.x, y: self.view.frame.height / 2, width: 1, height: 1)
        datePicker.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: 1)
        containerViewCancelButton.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: 1)
        containerViewSetDateButton.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: 1)
        
        UIView.animate(withDuration: 0.3) {
            self.containerView.frame = CGRect(x: 20 , y: self.view.frame.height / 2 - 200, width: self.view.frame.width - 40, height: 400)
            self.datePicker.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 40, height: 350)
            self.containerViewCancelButton.frame = CGRect(x: 0, y: self.datePicker.frame.height, width: (self.view.frame.width - 40) / 2, height: 50)
            self.containerViewSetDateButton.frame = CGRect(x: (self.view.frame.width - 40) / 2, y: self.datePicker.frame.height, width: (self.view.frame.width - 40) / 2, height: 50)
        }
    }
    
    fileprivate func removeDatePickerPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.frame = CGRect(x: self.view.center.x, y: self.view.frame.height / 2, width: 1, height: 1)
            self.datePicker.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: 1)
            self.containerViewCancelButton.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: 1)
            self.containerViewSetDateButton.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: 1)
        }) { (_) in
            self.containerView.removeFromSuperview()
        }
    }
    
    //Date Picker Popup
    // ------------------
    //Gender Picker Popup
    
    lazy var genderMaleImageView: UIView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "Male(Blue)")
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMaleClick)))
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    @objc func handleMaleClick(gesture: UITapGestureRecognizer) {
        print("male")
        self.genderInputView.textField.text = "Male"
        self.genderInputView.textField.resignFirstResponder()
    }
    
    let genderInset: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var genderFemaleImageView: UIView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = #imageLiteral(resourceName: "Female(Pink)")
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFemaleClick)))
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    @objc func handleFemaleClick(gesture: UITapGestureRecognizer) {
        print("female")
        self.genderInputView.textField.text = "Female"
        self.genderInputView.textField.resignFirstResponder()
    }
    
    fileprivate func setupGenderPopup() {
        view.addSubview(containerView)
        containerView.addSubview(genderMaleImageView)
        containerView.addSubview(genderFemaleImageView)
        containerView.addSubview(genderInset)
        
        containerView.frame = CGRect(x: view.center.x, y: self.view.frame.height / 2, width: 1, height: 1)
        genderMaleImageView.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: 1)
        genderInset.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        genderFemaleImageView.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: 1)
        
        UIView.animate(withDuration: 0.3) {
            self.containerView.frame = CGRect(x: 20 , y: self.view.frame.height / 2 - 75, width: self.view.frame.width - 40, height: 150)
            self.genderMaleImageView.frame = CGRect(x: 0, y: 15, width: ((self.view.frame.width - 40) / 2) - 0.5, height: 120)
            self.genderInset.frame = CGRect(x: ((self.view.frame.width - 40) / 2) - 0.5, y: 10, width: 1, height: 130)
            self.genderFemaleImageView.frame = CGRect(x: ((self.view.frame.width - 40) / 2) - 0.5, y: 15, width: (self.view.frame.width - 40) / 2, height: 120)
        }
    }
    
    fileprivate func removeGenderPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.frame = CGRect(x: self.view.center.x, y: self.view.frame.height / 2, width: 1, height: 1)
            self.genderMaleImageView.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: 1)
            self.genderInset.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
            self.genderFemaleImageView.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: 1)
        }) { (_) in
            self.containerView.removeFromSuperview()
        }
    }

    let emailTextField = LoginTextField()
    let nameTextField = LoginTextField()
    let birthdayTextField = LoginTextField()
    let genderTextField = LoginTextField()
    let interestedTextField = LoginTextField()
    let passwordTextField = LoginTextField()
    let confirmPasswordTextField = LoginTextField()
    let jobTextField = LoginTextField()
    
    let signupButton = LoginButton(color: offBlack, textColor: offerBlack, title: "Sign Up", font: UIFont(name: "Marker Felt", size: 16), cornerRadius: 10)
    let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .clear
        let attributedString = NSMutableAttributedString(string: "Already have an account? Sign in", attributes: [NSAttributedStringKey.font : UIFont(name: "Marker Felt", size: 14), NSAttributedStringKey.foregroundColor : UIColor.white])
        btn.setAttributedTitle(attributedString, for: .normal)
        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return btn
    }()
    
    @objc fileprivate func handleLogin() {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupLogoView() {
        view.addSubview(mainLogoLabel)
        mainLogoLabel.anchor(top: profileImageView.bottomAnchor, left: profileImageView.centerXAnchor, right: nil, bottom: nil, paddingTop: -100, paddingLeft: 50, paddingRight: 0, paddingBottom: 0, width: 75, height: 105)
        view.addSubview(secondaryLogoLabel)
        secondaryLogoLabel.anchor(top: nil, left: mainLogoLabel.rightAnchor, right: nil, bottom: mainLogoLabel.bottomAnchor, paddingTop: 0, paddingLeft: -24, paddingRight: 0, paddingBottom: 0, width: 0, height: 40)
    }
    
    var stackview = UIStackView()
    fileprivate func setupTextFields() {
        emailTextField.placeHolderLabel.text = "Email"
        emailTextField.textField.delegate = self
        emailTextField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        nameTextField.placeHolderLabel.text = "Name"
        nameTextField.textField.delegate = self
        nameTextField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        jobTextField.placeHolderLabel.text = "Work"
        jobTextField.textField.delegate = self
        jobTextField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        passwordTextField.placeHolderLabel.text = "Password"
        passwordTextField.textField.isSecureTextEntry = true
        passwordTextField.textField.delegate = self
        passwordTextField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        confirmPasswordTextField.placeHolderLabel.text = "Confirm"
        confirmPasswordTextField.textField.isSecureTextEntry = true
        confirmPasswordTextField.textField.delegate = self
        confirmPasswordTextField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        birthdayTextField.placeHolderLabel.text = "Birthday"
        birthdayTextField.textField.delegate = self
        birthdayTextField.textField.inputView = UIView()
        
        genderTextField.placeHolderLabel.text = "Gender"
        genderTextField.textField.delegate = self
        genderTextField.textField.inputView = UIView()
        
        interestedTextField.placeHolderLabel.text = "Interested"
        interestedTextField.textField.delegate = self
        interestedTextField.textField.inputView = UIView()
        
        stackview = UIStackView(arrangedSubviews: [emailTextField, nameTextField, jobTextField, passwordTextField, confirmPasswordTextField, birthdayTextField, genderTextField, interestedTextField])
        stackview.spacing = 8
        stackview.distribution = .fillEqually
        stackview.axis = .vertical
        view.addSubview(stackview)
        stackview.anchor(top: secondaryLogoLabel.bottomAnchor, left: nil, right: nil, bottom: nil, paddingTop: 40, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: self.view.frame.width - 40, height: (CGFloat(stackview.subviews.count) * (8.0 + self.view.frame.height/22.55)))
        stackview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setupAuthButtons() {
        view.addSubview(signupButton)
        signupButton.anchor(top: interestedTextField.bottomAnchor, left: interestedTextField.leftAnchor, right: interestedTextField.rightAnchor, bottom: nil, paddingTop: 12, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 40)
        signupButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        signupButton.isUserInteractionEnabled = false
        
        view.addSubview(loginButton)
        loginButton.anchor(top: signupButton.bottomAnchor, left: signupButton.leftAnchor, right: signupButton.rightAnchor, bottom: nil, paddingTop: 8, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 30)
    }
    
    var genderInputView = LoginTextField()
    
    fileprivate func setupPopup(loginInputView: LoginTextField) {
        if loginInputView == birthdayTextField {
            self.setupDatePickerPopup()
        } else if loginInputView == genderTextField || loginInputView == interestedTextField {
            self.setupGenderPopup()
            self.genderInputView = loginInputView
        } else {
            return
        }
    }
    
    fileprivate func removePopup(loginInputView: LoginTextField) {
        if loginInputView == birthdayTextField {
            self.removeDatePickerPopup()
        } else if loginInputView == genderTextField || loginInputView == interestedTextField {
            self.removeGenderPopup()
        } else {
            return
        }
    }
    
    
    @objc fileprivate func handleDismissKeyboard(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    var profileImageViewTopOrBottomAnchor = NSLayoutConstraint()
    fileprivate func setupViews() {
        view.backgroundColor = offerBlack
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboard)))
        view.addSubview(profileImageView)
        
        profileImageView.anchor(top: nil, left: nil, right: nil, bottom: nil, paddingTop: 10, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 180, height: 180)
        profileImageViewTopOrBottomAnchor = profileImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        profileImageViewTopOrBottomAnchor.isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddImage)))
        
        setupLogoView()
        setupTextFields()
        setupAuthButtons()
        
    }
    
    fileprivate func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChangeFrame), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc fileprivate func handleKeyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo, var keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        adjustTopConstaint(keyboardFlag: true)


    }
    
    @objc fileprivate func handleKeyboardWillHide(_ notification: Notification) {
        adjustTopConstaint(keyboardFlag: false)
    }
    
    fileprivate func adjustTopConstaint(keyboardFlag: Bool) {
        if keyboardFlag {
            profileImageViewTopOrBottomAnchor.isActive = false
            profileImageViewTopOrBottomAnchor = profileImageView.bottomAnchor.constraint(equalTo: view.topAnchor)
            profileImageViewTopOrBottomAnchor.isActive = true
        } else {
            profileImageViewTopOrBottomAnchor.isActive = false
            profileImageViewTopOrBottomAnchor = profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            profileImageViewTopOrBottomAnchor.isActive = true
        }
    
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in }
    }
    
    
    @objc fileprivate func handleAddImage(gesture: UITapGestureRecognizer) {
        let photoSelector = PhotoSelectorController(collectionViewLayout: UICollectionViewFlowLayout())
        photoSelector.signUpViewController = self
       // let navController = UINavigationController(rootViewController: photoSelector)
        present(photoSelector, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleSignUp() {
        print("Sign Up")
        
        if checkValidationOfInputFields() {
            guard let profileImage = profileImageView.image else { return }
            guard let email = emailTextField.textField.text else { return }
            guard let name = nameTextField.textField.text else { return }
            guard let job = jobTextField.textField.text else { return }
            guard let password = passwordTextField.textField.text, let confirm = confirmPasswordTextField.textField.text else { return }
        
            guard password == confirm else { appDelegate.errorView(message: "Passwords don't match, please try again.", color: .red); return }
            
            guard let gender = genderTextField.textField.text?.lowercased(),
                let interested = interestedTextField.textField.text?.lowercased(),
                let birthday = birthdayTextField.textField.text
                else { appDelegate.errorView(message: "Please set your matching preferences.", color: .red); return }
            
            AuthLayer.shared.createUser(email: email, password: password, name: name, image: profileImage, gender: gender, interested: interested, birthday: birthday, job: job, completion: { (success, error) in
                if let err = error {
                    appDelegate.errorView(message: err.localizedDescription, color: .red)
                    return
                }
                
                if success {
                    guard let mainPaginationController = UIApplication.shared.keyWindow?.rootViewController as? MainPagationController else { return }
                    mainPaginationController.setupControllersForPage()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("Unable to save user")
                }
            })
        } else {
            appDelegate.errorView(message: "Please fill in all the required information.", color: .red)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       changeSignUpButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupKeyboardObservers()
    }
    
    fileprivate func checkValidationOfInputFields() -> Bool{
        var count = 0
        for view in stackview.subviews {
            guard let inputView = view as? LoginTextField, inputView.textField.text != "" else { continue }
            count += 1
        }
        
        if count == stackview.subviews.count && profileImageView.image != nil && profileImageView.image != #imageLiteral(resourceName: "AddImage") {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func changeSignUpButton() {
        if checkValidationOfInputFields() {
            self.signupButton.backgroundColor = .lightGray
            self.signupButton.isUserInteractionEnabled = true
        } else {
            self.signupButton.backgroundColor = offBlack
            self.signupButton.isUserInteractionEnabled = false
        }
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let loginTextField = textField.superview as? LoginTextField else { return }
        setupPopup(loginInputView: loginTextField)
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
        removePopup(loginInputView: loginTextField)
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
        changeSignUpButton()
    }
    
    @objc func textFieldDidChange(_ textfield: UITextField) {
        changeSignUpButton()
    }
}





