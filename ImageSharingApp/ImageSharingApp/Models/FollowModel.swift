//
//  FollowModel.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2019-01-26.
//  Copyright © 2019 Noah Sjöberg. All rights reserved.
//

import Foundation


class FollowModel {
    
    
    private static func createFollowBody(username: String, password: String, userToFollow: String) -> Data? {
        let followDict = [
            "username": username,
            "password": password,
            "user_to_follow": userToFollow
        ]
        
        if let followData = try? JSONSerialization.data(withJSONObject: followDict, options: []) {
            return followData
        }
        return nil
    }
    
    static func follow(_ user: User, completion: @escaping (_ updatedUser: User?) -> ()) {
        if let followURL = URL(string: NetworkingConstants.followURLString), let password = User.activeUserPassword, let activeUser = User.activeUser {
            
            guard let followData = createFollowBody(username: activeUser.username, password: password, userToFollow: user.username) else {return}
            
            var followRequest = URLRequest(url: followURL)
            followRequest.httpBody = followData
            followRequest.httpMethod = HttpMethod.post.rawValue
            
            URLSession.shared.dataTask(with: followRequest) { (data, _, error) in
                if let data = data, error == nil {
                    // success
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                        let userDict = json as? [String:String] else {return}
                    
                    let updatedUser = User(from: userDict)
                    completion(updatedUser)
                } else {
                    completion(nil)
                }
                }.resume()
        }
    }
    
    
    static func doesFollow(user: User, completion: @escaping (_ doesFollow: Bool) -> ()) {
        
        guard let activeUser = User.activeUser, let url = NetworkingConstants.constructDoesFollowUrl(user: activeUser.username, specifiedUser: user.username) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let data = data, error == nil {
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let followsDict = json as? [String:String]else {return}
                let follows = followsDict["follows"] == "True" ? true : false
                completion(follows)
            } else {
                completion(false)
            }
            }.resume()
    }
    
    
    static func getFollowers(from username: String, completion: @escaping (_ users: [User]?) -> ()) {
        guard let url = NetworkingConstants.constructFollowersURL(username: username) else {return}
        User.getUsers(with: url) { (users) in
            if let users = users {
                completion(users)
            }
        }
    }
    
    static func getFollows(from username: String, completion: @escaping (_ users: [User]?) -> ()) {
        guard let url = NetworkingConstants.constructFollowsURL(username: username) else {return}
        User.getUsers(with: url) { (users) in
            completion(users)
        }
    }
    
}
