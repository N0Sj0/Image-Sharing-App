//
//  Keychain.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2019-01-28.
//  Copyright © 2019 Noah Sjöberg. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

struct Keychain {
    
    private static let usernameKey = "username"
    private static let passwordKey = "password"
    
    static func saveActiveUser(password: String) {
        if let activeUser = User.activeUser {
            KeychainWrapper.standard.set(activeUser.username, forKey: usernameKey)
            KeychainWrapper.standard.set(password, forKey: passwordKey)
        }
    }
    // Returns Username, Password
    static func getSavedActiveUserProperties() -> (String, String)? {
        
        let username = KeychainWrapper.standard.string(forKey: usernameKey)
        let password = KeychainWrapper.standard.string(forKey: passwordKey)
        
        if let username = username, let password = password {
            return (username, password)
        }
        return nil
    }
    
    static func deleteActiveUserProperties() {
        KeychainWrapper.standard.removeObject(forKey: usernameKey)
        KeychainWrapper.standard.removeObject(forKey: passwordKey)
    }
    
}
