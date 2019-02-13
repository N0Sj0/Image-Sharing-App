//
//  AppDelegate.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-10-31.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let userProperties = Keychain.getSavedActiveUserProperties()
        
        // If there is a saved user, Login
        if let username = userProperties?.0, let password = userProperties?.1 {
            login(username: username, password: password)
        }
        return true
    }
    
    
    private func login(username: String, password: String) {
        if let loginNavigationController = self.window?.rootViewController as? UINavigationController, let loginViewController = loginNavigationController.viewControllers.first as? LoginViewController {
            loginViewController.login(username: username, password: password)
        }
    }
    
}

