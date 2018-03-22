//
//  ImageViewMessageCell.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/13/18.
//  Copyright © 2018 andrewfoghel. All rights reserved. 
//

import UIKit

class ImageViewCollectionViewCell: UICollectionViewCell {
    
    var userImage: UserImage?
    
    let imageView = RoundImageView(color: .clear, cornerRadius: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
