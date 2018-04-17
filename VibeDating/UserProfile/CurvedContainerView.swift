//
//  CurvedContainerView.swift
//  VibeDating
//
//  Created by Andrew Foghel on 4/16/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

class CurvedContainerView: UIView {
    //USER PROFILE VC 2.3 --- CUSTOM CONTAINER VIEW
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        do {
            let path = UIBezierPath() //Create the path
            path.move(to: CGPoint(x: 0.0, y: 0.0)) //Give it a starting point
            path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height - 20)) //Get ready to get curvy
            path.addQuadCurve(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height - 20), controlPoint: CGPoint(x: rect.width/2, y: rect.height + 20)) // Hit the curve
            path.addLine(to: CGPoint(x: self.frame.size.width, y: 0.0)) // back to start
            path.close() //close
            
            let shapeLayer = CAShapeLayer() //make shape to overlay easier
            shapeLayer.path = path.cgPath
            
            self.layer.mask = shapeLayer
        }
    }
}
