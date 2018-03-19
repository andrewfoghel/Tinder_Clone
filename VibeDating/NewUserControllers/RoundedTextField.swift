//
//  RoundedTextField.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/3/18.
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
