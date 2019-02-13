//
//  NetworkingConstants.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-01.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import Foundation

enum HttpMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
}

struct NetworkingTasks {
    static var loginTask: URLSessionDataTask?
    static var registerTask: URLSessionDataTask?
}

struct NetworkingConstants {
    private static let baseUrl = "http://http://127.0.0.1:8000/"
    private static let usersPath = "users/"
    private static let loginPath = "login/"
    private static let setProfileImagePath = "profile_image/"
    private static let postsPath = "posts/"
    private static let searchPath = "search/"
    private static let followPath = "follow/"
    private static let userPostPath = "userposts/"
    private static let feedPath = "feed/"
    private static let followersPath = "followers/"
    private static let followsPath = "follows/"
    private static let isLikingPath = "is_liking/"
    private static let getLikersPath = "likers/"
    private static let commentPath = "comment/"
}

extension NetworkingConstants {
    
    // MARK: - Search
    static func constructSearchUrl(searchString: String) -> URL?{
        let fullsearchURLString = searchURLString + "?search_string=\(searchString)"
        
        return URL(string: fullsearchURLString)
    }
    
    // MARK: - Like
    
    static func constructLikeURL(postId: Int) -> URL? {
        let likeURLString = baseUrl + postsPath + "\(postId)/" + "like/"
        
        return URL(string: likeURLString)
    }
    
    static func contructGetLikersURL(owner: String, post_id: String) -> URL? {
        let urlString = baseUrl + postsPath + "\(post_id)/" + getLikersPath + "?owner=\(owner)"
        
        return URL(string: urlString)
    }
    
    static func constructGetLikedStatusOnPostURL(user: String, post_id: String, owner: String) -> URL? {
        let urlString = baseUrl + postsPath + "\(post_id)/" + isLikingPath + "?user=\(user)&owner=\(owner)"
        
        return URL(string: urlString)
    }
    
    
    // MARK: - Feed
    
    static func constructFeedURL(username: String, from num: Int) -> URL? {
        let fullFeedPostsURLString = baseUrl + feedPath + "?username=\(username)" + "&num=\(num)"
        
        return URL(string: fullFeedPostsURLString)
    }
    
    
    // MARK: - User

    static func constructSetProfileImageURLString(username:String) -> String{
        let fullSetProfileImageURLString = baseUrl + usersPath + "\(username)/" + setProfileImagePath
        
        return fullSetProfileImageURLString
    }
    
    
    static func constructGetUserURL(user: String) -> URL? {
        let urlString = baseUrl + usersPath + "\(user)/"
        
        return URL(string: urlString)
    }
    
    static func constructUpdateUserURL(username: String) -> URL? {
        let updateUserURLString = baseUrl + usersPath + "\(username)/"
        
        return URL(string: updateUserURLString)
    }
    

    // MARK: - Follow & Follows
    
    // Follow another user
    static var followURLString: String {
        return baseUrl + followPath
    }
    
    // get followers of a user
    static func constructFollowersURL(username: String) -> URL? {
        return URL(string: baseUrl + usersPath + "\(username)/" + followersPath)
    }
    
    static func constructFollowsURL(username: String) -> URL? {
        return URL(string: baseUrl + usersPath + "\(username)/" + followsPath)
    }

    static func constructDoesFollowUrl(user: String, specifiedUser: String) -> URL? {
        let fullFollowURLString = baseUrl + followPath + "?user=\(user)&specified_user=\(specifiedUser)"
        
        return URL(string: fullFollowURLString)
    }
    
    // MARK: - Search
    static var searchURLString: String {
        return baseUrl + searchPath
    }
    
    // MARK: - Post & Comment
    static var commentURL: URL? {
        return URL(string: baseUrl + commentPath)
    }
    
    static var postsURLString: String {
        return baseUrl + postsPath
    }
    
    static func constructCommentURL(postId:Int) -> URL? {
        let commentURLString = baseUrl + postsPath + "\(postId)/" + commentPath
        
        return URL(string: commentURLString)
    }
    
    
    // owner: The one using the app, username: the one who has the posts
    static func constructUserPostsURL(owner: String, username: String) -> URL? {
        let fullUserPostsURLString = baseUrl + usersPath + "\(username)/" + postsPath  + "?owner=\(owner)"
        
        return URL(string: fullUserPostsURLString)
    }
    
    
    // MARK: - Authentication
    static var registerURL: URL? {
        let registerURLString = baseUrl + usersPath
        return URL(string: registerURLString)
    }
    
    static var loginURL: URL? {
        let loginURLString = baseUrl + loginPath
        return URL(string: loginURLString)
    }
    
    
}
