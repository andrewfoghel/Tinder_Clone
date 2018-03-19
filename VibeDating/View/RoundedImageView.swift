//
//  RoundedImageView.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/4/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

var imageCache = [String : UIImage]()

class RoundImageView: UIImageView {
   
    var user = MyUser()
    
    convenience init(color: UIColor, cornerRadius: CGFloat, tag: Int? = 0) {
        self.init()
        
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.isUserInteractionEnabled = true
        self.image = #imageLiteral(resourceName: "AddImage")
        self.backgroundColor = color
        self.contentMode = .scaleAspectFill
        self.tag = tag!
        
        
    }
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err = error {
                print("Failed to fetch image for cell", err.localizedDescription)
                return
            }
            
            if url.absoluteString != self.lastURLUsedToLoadImage { return }
            
                guard let data = data else { return }
                let photoImage = UIImage(data: data)
            
                imageCache[url.absoluteString] = photoImage
            
                DispatchQueue.main.async {
                    self.image = photoImage
                }
            }.resume()
        }
    
}
