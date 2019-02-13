//
//  Post.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-11.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Post {
    
    var image: UIImage?
    var postImageURL: URL?
    var description: String
    var owner: User
    var likes: Int
    var id: Int
    var activeUserIsLiking: Bool?
    var comments: [Comment]?
    var date: String
    
    
    // the amount of posts the server returns to the feed at a time, if it returns less then is all posts allready fetched
    static let maxPostsPerRequest = 15
    
    init(postImageURL: URL, description: String, owner: User, likes: Int, id: Int, date: String, activeUserIsLiking: Bool? = nil, comments: [Comment]? = nil) {
        self.likes = likes
        self.postImageURL = postImageURL
        self.description = description
        self.owner = owner
        self.id = id
        self.date = date
        self.activeUserIsLiking = activeUserIsLiking
        self.comments = comments
    }
    
    convenience init?(from postDict: [String:Any], owner: User) {
        
        guard let postImageURLString = postDict["image_url"] as? String,
            let description = postDict["description"] as? String,
            let likes = Int(postDict["string_likes"] as? String ?? "0"),
            let id = Int(postDict["post_id_string"] as? String ?? "0"),
            let date = postDict["date_string"] as? String else {return nil}
        
        let activeUserIsLiking = (postDict["user_is_liking"] as? String ?? "") == "True" ? true : false
        
        var comments = [Comment]()
        if let commentDicts = postDict["comments"] as? [[String:String]] {
            for commentDict in commentDicts {
                guard let text = commentDict["text"],
                    let ownerString = commentDict["owner_string"] else {continue}
                let comment = Comment(text: text, ownerString: ownerString)
                comments.append(comment)
            }
        }
        
        if let postImageURL = URL(string: postImageURLString) {
            self.init(postImageURL: postImageURL, description: description, owner: owner, likes: likes, id: id, date: date, activeUserIsLiking: activeUserIsLiking, comments: comments)
        } else {
            return nil
        }
    }
    
}


// upload the post
extension Post {
    
    static private func createUploadBody(username: String, password: String, description: String) -> Data? {
        let uploadDict = [
            "username"    : username,
            "password"    : password,
            "description" : description
        ]
    
        guard let uploadData = try? JSONSerialization.data(withJSONObject: uploadDict, options: []) else { return nil }
        
        return uploadData
    }
    
    static func uploadPost(description: String, postImage: UIImage, completion: @escaping (_ newPost: Post?) -> ()) {
        
        let resizedPostImage = ImageResizer.resizeImage(image: postImage, newWidth: ImageConstants.postImageWidth, newHeight: ImageConstants.postImageHeight)
        
        guard let username = User.activeUser?.username, let owner = User.activeUser, let password = User.activeUserPassword,
            let postURL = URL(string: NetworkingConstants.postsURLString),
            let uploadJsonData = Post.createUploadBody(username: username, password: password, description: description),
            let imageData = resizedPostImage.pngData() else {return}
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(uploadJsonData, withName: "json", fileName: "json", mimeType: "text/plain")
            multipartFormData.append(imageData, withName: "image", fileName: "image", mimeType: "image/png")
        }, usingThreshold: UInt64.init(),
           to: postURL,
           method: .post,
           headers: [:]) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (response) in
                    if let data = response.data {
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                            let postDict = json as? [String:Any] else {completion(nil); return}
                        let newPost = Post(from: postDict, owner: owner)
                        completion(newPost)
                    }
                })
                
            case .failure(_):
                completion(nil)
            }
        }
    }
}


// MARK: - Get
extension Post {
    
    static func getPosts(from owner: User, user: User, completion: @escaping (_ posts: [Post]?) -> ()) {
        
        guard let userPostsURL = NetworkingConstants.constructUserPostsURL(owner: owner.username, username: user.username) else {return}
        
        URLSession.shared.dataTask(with: userPostsURL) { (data, _, error) in
            if let data = data, error == nil {
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let postsJson = json as? [[String:Any]] else {return}
                
                var posts = [Post]()
                for postJson in postsJson {
                    if let post = Post(from: postJson, owner: owner) {
                        posts.append(post)
                        
                    }
                }
                completion(posts)
            } else {
                completion(nil)
            }
            }.resume()
    }
    
    func getPostImage(completion: @escaping () -> ()) {
        
        if let postImageURL = postImageURL {
            URLSession.shared.dataTask(with: postImageURL) { (data, _, error) in
                if let data = data, error == nil {
                    self.image = UIImage(data: data)
                    completion()
                }
                }.resume()
        }
    }
    
    func getLikers(completion: @escaping (_ users: [User]?) -> ()) {
        
        guard let url = NetworkingConstants.contructGetLikersURL(owner: owner.username, post_id: String(id)) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let data = data, error == nil {
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let usersDicts = json as? [[String:String]] else {return}
                
                var users = [User]()
                for userDict in usersDicts {
                    if let user = User(from: userDict) {
                        users.append(user)
                    }
                }
                completion(users)
            }
            }.resume()
    }
}

