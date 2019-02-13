//
//  SearchModel.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2019-01-26.
//  Copyright © 2019 Noah Sjöberg. All rights reserved.
//

import Foundation


class SearchModel {
    
    static func searchForUser(with searchString: String, completion: @escaping (_ users: [User]?) -> ())  {
        
        guard let searchURL = NetworkingConstants.constructSearchUrl(searchString: searchString) else {return}
        
        URLSession.shared.dataTask(with: searchURL) { (data, _, error) in
            if let data = data, error == nil {
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let usersJson = json as? [[String:String]] else {return}
                
                var users = [User]()
                
                for userJson in usersJson {
                    if let user = User(from: userJson) {
                        users.append(user)
                    }
                }
                completion(users)
            } else {
                completion(nil)
            }
            }.resume()
        
    }
    
}
