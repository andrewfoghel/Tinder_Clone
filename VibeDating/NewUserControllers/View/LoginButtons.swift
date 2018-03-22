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
        self.backgroundColor = color
      //  self.layer.borderWidth = 2
        self.layer.cornerRadius = cornerRadius
        let attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor : textColor])
        self.setAttributedTitle(attributedString, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
}
