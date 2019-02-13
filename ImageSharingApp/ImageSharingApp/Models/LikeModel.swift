//
//  LikeModel.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2019-01-26.
//  Copyright © 2019 Noah Sjöberg. All rights reserved.
//

import Foundation



class LikeModel {
    
    private static func createLikeBody(with post: Post) -> Data? {
        
        var likeDict = [String: String]()
        
        guard let activeUser = User.activeUser, let password = User.activeUserPassword else {return nil}
        
        likeDict["username"] = activeUser.username
        likeDict["password"] = password
        likeDict["owner_string"] = post.owner.username
        
        guard let data = try? JSONSerialization.data(withJSONObject: likeDict, options: []) else {return nil}
        
        return data
        
    }
    
    static func like(post: Post, completion: @escaping (_ post: Post?) -> ()) {
        
        guard let likeURL = NetworkingConstants.constructLikeURL(postId: post.id),
            let likeBody = createLikeBody(with: post) else {return}
        
        var likeRequest = URLRequest(url: likeURL)
        likeRequest.httpBody = likeBody
        likeRequest.httpMethod = "POST"
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: likeRequest) { (data, _, error) in
            if let data = data, error == nil {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let postDict = json as? [String:Any] else {return}
                
                let likedPost = Post(from: postDict, owner: post.owner)
                likedPost?.activeUserIsLiking = post.activeUserIsLiking
                completion(likedPost)
            }
            }.resume()
        
    }
    
}
