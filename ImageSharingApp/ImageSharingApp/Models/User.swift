//
//  User.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-01.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftKeychainWrapper


class User {
    
    // Contains all fetched users
    static var users = [String: User]()
    
    var fullName: String {
        return firstname + " " + lastname
    }
    
    var followers:[User]?
    var follows:[User]?
    
    var followersCount: Int
    var followsCount: Int
    
    var username: String
    var firstname: String
    var lastname: String
    var bio: String?
    
    var profileImage: UIImage?
    var profileImageUrl: URL?
    
    
    init(username: String, firstname: String, lastname: String, profileImageURLString: String? = nil, bio: String? = nil, followsCount: Int, followersCount: Int) {
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
        self.bio = bio
        self.followsCount = followsCount
        self.followersCount = followersCount
        
        if let profileImageURL = URL(string: profileImageURLString ?? "") {
            self.profileImageUrl = profileImageURL
        }
    }
    
    init?(from userDict: [String:String]) {
        
        if let username = userDict["username"] {
            self.followsCount = Int(userDict["string_follows_count"] ?? "0")!
            self.followersCount = Int(userDict["string_followers_count"] ?? "0")!
            self.username = username
            firstname = userDict["firstname"] ?? ""
            lastname = userDict["lastname"] ?? ""
            bio = userDict["bio"] ?? ""
            if let profilePicUrlSting = userDict["profile_pic_url"] {
                profileImageUrl = URL(string: profilePicUrlSting)
            }
        } else {
            return nil
        }
    }
}

// MARK: - Update
extension User {
    
    func updateProfile(password: String, completion: @escaping (_ user: User?) -> ()) {
        guard let updateURL = NetworkingConstants.constructUpdateUserURL(username: username) else {return}
        
        var updateUserDict = User.userToDict(user: self)
        updateUserDict["password"] = password
        guard let updateBody = try? JSONSerialization.data(withJSONObject: updateUserDict, options: []) else {return}
        
        var updateRequest = URLRequest(url: updateURL)
        updateRequest.httpMethod = "PUT"
        updateRequest.httpBody = updateBody
        
        
        URLSession.shared.dataTask(with: updateRequest) { (data, _, error) in
            if let data = data, error == nil {
                // success
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {return}
                guard let userDict = json as? [String:String] else {return}
                let updatedUser = User(from: userDict)
                completion(updatedUser)
            } else {
                // fail
                completion(nil)
            }
            }.resume()
    }
    
}


// MARK: - ProfileImage
extension User {
    
    func getProfileImage(completion: @escaping () -> () = {}) {
        
        guard let profilePicURL = profileImageUrl else {completion(); return }
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        
        URLSession(configuration: configuration).dataTask(with: profilePicURL) { (data, _, error) in
            if let data = data, error == nil {
                let profilePic = UIImage(data: data) ?? UIImage(named: ImageConstants.userImagePlaceholderId)
                self.profileImage = profilePic
            }
            completion()
            }.resume()
    }
    
    
    func setProfilePicture(profilePicture: UIImage, password: String, completion: @escaping (_ updatedUser: User?) -> ()) {
        
        let userDict = ["username": username, "password": password]
        guard let userJsonData = try? JSONSerialization.data(withJSONObject: userDict, options: []) else { return }
        
        let resizedProfilePicture = ImageResizer.resizeImage(image: profilePicture, newWidth: ImageConstants.profileImageWidth, newHeight: ImageConstants.profileImageHeight)
        guard let imageData = resizedProfilePicture.pngData() else { return }
        
        Alamofire.upload(multipartFormData: { (multiPartFormData) in
            multiPartFormData.append(userJsonData, withName: "json", fileName: "json", mimeType: "text/plain")
            multiPartFormData.append(imageData, withName: "profileImage", fileName: "profileImage", mimeType: "image/png")
        }, usingThreshold: UInt64.init(),
           to: NetworkingConstants.constructSetProfileImageURLString(username: username),
           method: .post,
           headers: [:]) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (response) in
                    if let data = response.data {
                        // got data, return updated user
                        guard let json = try? JSONSerialization.jsonObject(with: data , options: []) else {return}
                        let userDict = json as? [String:String] ?? [:]
                        let updatedUser = User(from: userDict)
                        completion(updatedUser)
                    }
                })
            case .failure(_):
                completion(nil)
            }
        }
    }
    
}

// Method to turn User into a dictionary
extension User {
    
    static func userToDict(user: User) -> [String:String] {
        
        var userDict = [String:String]()
        
        userDict["username"] = user.username
        userDict["bio"] = user.bio ?? ""
        userDict["firstname"] = user.firstname
        userDict["lastname"] = user.lastname
        userDict["profile_pic_url"] = user.profileImageUrl?.absoluteString ?? ""
        
        return userDict
    }
    
}


extension User {
    
    // Followers and follows
    static func getUsers(with url: URL, completion: @escaping (_ users: [User]?) -> ()) {
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let data = data, error == nil {
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let usersJson = json as? [[String: String]] else {return}
                
                var users = [User]()
                
                for userJson in usersJson {
                    if let user = User(from: userJson) {
                        users.append(user)
                    }
                }
                completion(users)
            }
            }.resume()
    }

    
    func getFollowers(completion: @escaping (_ success: Bool) -> ()) {
        guard let url = NetworkingConstants.constructFollowersURL(username: username) else {return}
        User.getUsers(with: url) { (users) in
            if let users = users {
                self.followers = users
                completion(true)
            }  else {
                completion(false)
            }
        }
    }
    
    func getFollows(completion: @escaping (_ success: Bool) -> ()) {
        guard let url = NetworkingConstants.constructFollowsURL(username: username) else {return}
        User.getUsers(with: url) { (users) in
            if let users = users {
                self.follows = users
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}

