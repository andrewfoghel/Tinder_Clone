//
//  LoginButtons.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/3/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

class LoginButton: UIButton {
    convenience init(color: UIColor, textColor: UIColor, title: String, font: UIFont?, cornerRadius: CGFloat) {
        self.init()
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = cornerRadius
        self.setTitle(title, for: .normal)
        self.setTitleColor(textColor, for: .normal)
        self.titleLabel?.font = font
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }
}
