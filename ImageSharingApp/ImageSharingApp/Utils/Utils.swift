//
//  Utils.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2019-01-21.
//  Copyright © 2019 Noah Sjöberg. All rights reserved.
//

import Foundation

class LayoutUtils {
    static func calculateCommentLblHeight(comment: Comment, tableViewWidth: Int) -> Int {
        let commentTextWidth = Double(comment.text.count * LayoutConstants.average17PCharWidth)
        let commentLblWitdth = Double(tableViewWidth - LayoutConstants.CommentCellConstants.totalSpaceBetweenCommentLblAndView)
        let commentLblRows = Int(ceil(commentTextWidth / commentLblWitdth))
        
        let commentLblHeight = commentLblRows * LayoutConstants.CommentCellConstants.labelRowHeight
        
        return commentLblHeight
    }
}

class UserUtils {
    static func createUserJson(username: String, password: String) -> Data? {
        let bodyDict = ["username": username, "password": password]
        guard let body = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {return nil}
        return body
    }
}
