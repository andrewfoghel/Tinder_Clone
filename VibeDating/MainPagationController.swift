//
//  UserProfileViewController.swift
//  VibeDating
//
//  Created by Andrew Foghel on 3/3/18.
//  Copyright © 2018 andrewfoghel. All rights reserved.
//

import UIKit
import CoreLocation

var currentCoordinate = CLLocationCoordinate2D()

class MainPagationController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    let locationManager = CLLocationManager()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [UserProfileViewController(), MatchingViewController(), MessageLogTableViewController()]
    }()
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        let prevIndex = viewControllerIndex - 1
        guard prevIndex >= 0 else { return nil }
        guard orderedViewControllers.count > prevIndex else { return nil }
        
        return orderedViewControllers[prevIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard orderedViewControllers.count != nextIndex else { return nil }
        guard orderedViewControllers.count > nextIndex else { return nil }
    
        return orderedViewControllers[nextIndex]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if AuthLayer.shared.myUser == nil {
            DispatchQueue.main.async {
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        AuthLayer.shared.getUser { (user, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            guard let user = user else { return }
            currentUser = user
            
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.startUpdatingLocation()
            }
            self.attemptSetNewCoordinates()
            self.setupControllersForPage()
        }
    }
    
    var timer: Timer?
    fileprivate func attemptSetNewCoordinates() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setNewCoordinates), userInfo: nil, repeats: false)
    }
    
    @objc fileprivate func setNewCoordinates() {
        currentUser.lat = currentCoordinate.latitude
        currentUser.lon = currentCoordinate.longitude
        print(currentUser)
    }
    
    func setupControllersForPage() {
        self.delegate = self
        self.dataSource = self
        orderedViewControllers = [UserProfileViewController(), MatchingViewController(),MessageLogTableViewController()]
        
        let matchingVC = orderedViewControllers[1]
        self.setViewControllers([matchingVC], direction: .forward, animated: true, completion: nil)
    }
    
}

extension MainPagationController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinates = locationManager.location?.coordinate else { return }
        currentCoordinate = coordinates
        self.locationManager.stopUpdatingLocation()
        DatabaseLayer.shared.saveUserLocation(lat: coordinates.latitude, lon: coordinates.longitude)
    }
}
