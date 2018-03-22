        //
//  AppDelegate.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/3/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        
//        do {
//            try Auth.auth().signOut()
//            print("logged out")
//        } catch {
//            
//        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainPageVC = MainPagationController()
        window!.rootViewController = mainPageVC
        window!.makeKeyAndVisible()
        
        return true
    }
    
    var errorViewIsShowing = false
    func errorView(message: String, color: UIColor) {
        if !errorViewIsShowing {
            errorViewIsShowing = true
            
            let errorViewHeight = self.window!.bounds.height / 10
            let errorViewYOrigin = -errorViewHeight
            let errorView = UIView(frame: CGRect(x: 0, y: errorViewYOrigin, width: self.window!.bounds.width, height: errorViewHeight))
            errorView.backgroundColor = color
            self.window!.addSubview(errorView)
            
            let errorLabelWidth = errorView.bounds.width
            let errorLabelHeight = errorView.bounds.height + UIApplication.shared.statusBarFrame.height / 2
            let errorLabel = UILabel()
            errorLabel.frame.size.width = errorLabelWidth
            errorLabel.frame.size.height = errorLabelHeight
            errorLabel.textColor = .white
            errorLabel.text = message
            errorLabel.numberOfLines = 0
            errorLabel.font = UIFont(name: "Marker Felt", size: 12)
            errorLabel.textAlignment = .center
            
            errorView.addSubview(errorLabel)
            
            UIView.animate(withDuration: 0.2, animations: {
                errorView.frame.origin.y = 0
            }, completion: { (finished) in
                if finished {
                    UIView.animate(withDuration: 0.2, delay: 3, options: .curveLinear, animations: {
                        errorView.frame.origin.y = errorViewYOrigin
                    }, completion: { (finished) in
                        if finished {
                            errorView.removeFromSuperview()
                            errorLabel.removeFromSuperview()
                            self.errorViewIsShowing = false
                        }
                    })
                }
            })
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

