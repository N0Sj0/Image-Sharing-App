//
//  Feed.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2019-01-27.
//  Copyright © 2019 Noah Sjöberg. All rights reserved.
//

import Foundation


class Feed {
    
    static func getFeed(num: Int, completion: @escaping (_ users: [String:User]?, _ posts: [Post]?) -> ()) {
        
        guard let user = User.activeUser, let feedURL = NetworkingConstants.constructFeedURL(username: user.username, from: num) else {return}
        
        URLSession.shared.dataTask(with: feedURL) { (data, _, error) in
            if let data = data, error == nil {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let jsonDict = json as? [String: [[String: Any]]],
                    let usersJson = jsonDict["users"] as? [[String:String]],
                    let postsJson = jsonDict["posts"] else {return}
                
                var owners = [String:User]()
                var posts = [Post]()
                
                for userJson in usersJson {
                    if let user = User(from: userJson) {
                        owners[user.username] = user
                        if(User.users[user.username] == nil) {
                            User.users[user.username] = user
                        }
                    }
                }
                
                for postDict in postsJson {
                    if let ownersUsername = postDict["owner_string"] as? String,
                        let owner = owners[ownersUsername], let post = Post(from: postDict, owner: owner) {
                        posts.append(post)
                    }
                }
                
                completion(owners, posts)
            } else {
                completion(nil, nil)
            }
            }.resume()
    }
    
}
