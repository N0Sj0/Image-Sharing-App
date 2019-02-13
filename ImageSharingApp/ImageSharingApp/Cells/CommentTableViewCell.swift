
//
//  CommentTableViewCell.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-12-05.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import UIKit

protocol CommentTableViewCellDelegate {
    func didPressOnComment(user: User)
}

class CommentTableViewCell: UITableViewCell {
    
    var delegate:CommentTableViewCellDelegate?
    
    var comment: Comment? {
        didSet {
            comment?.delegate = self
            comment?.getOwner()
            setUp()
        }
    }
    
    @IBOutlet weak var ownerProfileImage: RoundUIImageView! {
        didSet {
            let touchRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedCommentUser))
            ownerProfileImage.addGestureRecognizer(touchRecognizer)
            ownerProfileImage.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var ownerUsernameLbl: UILabel! {
        didSet {
            let touchRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedCommentUser))
            ownerUsernameLbl.addGestureRecognizer(touchRecognizer)
            ownerUsernameLbl.isUserInteractionEnabled = true
        }

    }
    @IBOutlet weak var commentTxtLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        comment?.delegate = self
    }
    
}

extension CommentTableViewCell {
    private func setUp() {
        DispatchQueue.main.async {
            
            self.ownerProfileImage.image = self.comment?.owner?.profileImage ?? UIImage(named: ImageConstants.userImagePlaceholderId)
            self.ownerUsernameLbl.text = self.comment?.ownerString
            self.commentTxtLbl.text = self.comment?.text
        }
    }
    
    @objc private func pressedCommentUser() {
        if let delegate = delegate, let user = comment?.owner {
            delegate.didPressOnComment(user: user)
        }
    }
}

extension CommentTableViewCell: CommentDelegate {
    func gotUser() {
        setUp()
    }
}
