//
//  LayoutConstants.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-08.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import Foundation
import UIKit


struct LayoutConstants {
    
    static let average17PCharWidth = 8
    
    // how many unseen posts left in the feed before loading more
    static let postsLeftBeforeLoadingMore = 3
    
    
    struct FeedCellConstants {
        static let labelRowHeight = 25
        static let averageCommentHeight = 75
        static let profileImageHeight = 90
        static let utilsHeight = 30
        static let constraintsHeight = 30
        
        static func calculateLblHeight(descriptionCount: Int, labelWidth: Double) -> Int {
            let labelRows = Int(max(ceil(Double(descriptionCount * LayoutConstants.average17PCharWidth) / labelWidth), 1))
            let labelHeight = labelRows * LayoutConstants.FeedCellConstants.labelRowHeight
            
            return labelHeight
        }
        
        static func calculateCommentsHeight(commentsCount: Int) -> Int{
            let commentsHeight = min(LayoutConstants.FeedCellConstants.averageCommentHeight * commentsCount, 150)
            
            return commentsHeight
        }
    }
    
    struct CommentCellConstants {
        static let labelRowHeight = 25
        static let usernameHeight = 25
        static let constraintsHeight = 15
        static let totalSpaceBetweenCommentLblAndView = 85
    }
    
}

struct LoadingAlertConstants {
    static let spinnerSide: CGFloat = 50
    static let spinnerYOffset: CGFloat = 30
    static let spinnerLineWidth: CGFloat = 5.0
    static let spinnerColor: CGColor = UIColor.blue.cgColor
    static let spinnerAnimationDuration: Double = 2
    
    
    static let cancelBtnHeight: CGFloat = 25
    static let cancelBtnWidth: CGFloat = 100
    static let cancelBtnYOffsetFromCenter: CGFloat = 38
}
