//
//  CustomAnimationDismisser.swift
//  VibeDating
//
//  Created by Andrew Foghel on 4/20/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit

class CustomAnimationDismisser: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else { return }
        containerView.addSubview(toView)
        let startFrame = CGRect(x: toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        toView.frame = startFrame
        guard let fromView = transitionContext.view(forKey: .from) else { return}
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            fromView.frame = CGRect(x: -fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}
