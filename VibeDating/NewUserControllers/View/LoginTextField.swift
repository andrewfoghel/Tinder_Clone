//
//  LoginTextField.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/20/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

class RoundedTextField: UITextField {
    
    convenience init(color: UIColor, font: UIFont?, cornerRadius: CGFloat, placeHolder: String) {
        self.init()
        
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: self.frame.height))
        self.leftView = padding
        self.leftViewMode = .always
        
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = cornerRadius
        self.font = font
        self.textColor = color
        self.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSAttributedStringKey.foregroundColor : color])
    }
}

class LoginTextField: UIView {
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.font = UIFont(name: "Marker Felt", size: 16)
        tf.tintColor = .white
        return tf
    }()
    
    let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 0.5
        view.layer.masksToBounds = true
        return view
    }()
    
    var placeHolderLeftOrRightAnchor = NSLayoutConstraint()
    
    let placeHolderLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "Marker Felt", size: 14)
        lbl.textColor = .lightGray
        lbl.alpha = 0.5
        lbl.textAlignment = .left
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textField)
        addSubview(underlineView)
        addSubview(placeHolderLabel)
        
        textField.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 4, paddingRight: 4, paddingBottom: 0, width: 0, height: 20)
        underlineView.anchor(top: textField.bottomAnchor, left: leftAnchor, right: rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 1)
        
        
        placeHolderLabel.anchor(top: nil, left: nil, right: nil, bottom: underlineView.bottomAnchor, paddingTop: 0, paddingLeft: 4, paddingRight: 4, paddingBottom: 0, width: 100, height: 0)
        placeHolderLeftOrRightAnchor = placeHolderLabel.leftAnchor.constraint(equalTo: underlineView.leftAnchor, constant: -2)
        placeHolderLeftOrRightAnchor.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
