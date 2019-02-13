//
//  Authentication.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2019-01-27.
//  Copyright © 2019 Noah Sjöberg. All rights reserved.
//

import Foundation

enum RegisterError {
    case UsernameTaken
    case NoResponse
}

class Authentication {

    
    static func login(username: String, password: String, completion: @escaping (_ user: User?) -> ()) {
        
        guard let loginURL = NetworkingConstants.loginURL, let body = UserUtils.createUserJson(username: username, password: password) else {return}
        
        var loginRequest = URLRequest(url: loginURL)
        loginRequest.httpMethod = "POST"
        loginRequest.httpBody = body
        
       let loginTask = URLSession.shared.dataTask(with: loginRequest) { (data, _, error) in
            if let data = data, error == nil {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {return}
                let userDict = json as? [String:String] ?? [:]
                
                let user = User(from: userDict)
                User.activeUser = user
                User.activeUserPassword = password
                Keychain.saveActiveUser(password: password)
                completion(user)
            }
            }
        loginTask.resume()
        NetworkingTasks.loginTask = loginTask
    }

    static func registerUser(username: String, password: String, completion: @escaping (_ user: User?, _ error: RegisterError?) -> ()) {
        
        guard let registerUrl = NetworkingConstants.registerURL, let body = UserUtils.createUserJson(username: username, password: password) else {return}
        
        var request = URLRequest(url: registerUrl)
        request.httpMethod = "POST"
        request.httpBody = body
        
        let registerTask = URLSession.shared.dataTask(with: request) {(data, response, error) in
            let response = response as? HTTPURLResponse
            if error == nil, 200...299 ~= response?.statusCode ?? 0, let data = data {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:String] ?? [:] else {return}
                let user = User(from: json)
                completion(user, nil)
            } else if response?.statusCode ?? 0 == 401 {
                completion(nil, .UsernameTaken)
            } else {
                completion(nil, .NoResponse)
            }
            }
        registerTask.resume()
        NetworkingTasks.registerTask = registerTask
    }
    
}

// MARK: - CancelTasks
extension Authentication {
    static func cancelLoginTask() {
        if let loginTask = NetworkingTasks.loginTask {
            loginTask.cancel()
            NetworkingTasks.loginTask = nil
        }
    }
    
    static func cancelRegisterTask() {
        if let registerTask = NetworkingTasks.registerTask {
            registerTask.cancel()
            NetworkingTasks.registerTask = nil
        }
        
    }
}
