//
//  Comment.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-12-04.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import Foundation


protocol CommentDelegate {
    func gotUser()
}

class Comment {
    
    var delegate: CommentDelegate?
    var text: String
    var ownerString: String
    
    var owner: User? {
        didSet {
            if owner?.profileImage == nil {
                owner?.getProfileImage {
                    if let delegate = self.delegate {
                        delegate.gotUser()
                    }
                }
            }
        }
    }
    
    init(text: String, ownerString: String) {
        self.text = text
        self.ownerString = ownerString
    }
    
}

extension Comment {
    
    func getOwner() {
        
        if let owner = User.users[ownerString] {
            self.owner = owner
            return
        }
        guard let url = NetworkingConstants.constructGetUserURL(user: ownerString) else {return}
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { (data, _, error) in
            if let data = data, error == nil {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let userDict = json as? [String:String] else {return}
                
                let owner = User(from: userDict)
                self.owner = owner
                
                User.users[self.ownerString] = owner
            }
        }.resume()
    }
    
}


extension Comment {
    
    private static func createCommentBody(post: Post, text: String) -> Data? {
        
        if let activeUser = User.activeUser, let password = User.activeUserPassword {
            let commentDict = [
                "comment_text": text,
                "username": activeUser.username,
                "password": password,
                "post_owner": post.owner.username,
                "post_id": String(post.id)
            ]
            let data = try? JSONSerialization.data(withJSONObject: commentDict, options: [])
            
            return data
        }
        return nil
    }
    
    
    static func comment(post: Post, with text: String, completion: @escaping (_ success: Bool) -> ()) {
    
        guard let url = NetworkingConstants.constructCommentURL(postId: post.id), let commentBody = Comment.createCommentBody(post: post, text: text) else {return}
        
        var request = URLRequest(url: url)
        request.httpBody = commentBody
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil, let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    completion(true)
                } else if httpResponse.statusCode == 400 {
                    completion(false)
                }
            }
            
        }.resume()
    }
    
    
}
