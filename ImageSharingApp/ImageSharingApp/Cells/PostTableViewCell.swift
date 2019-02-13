//
//  PostTableViewCell.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-16.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import UIKit


protocol PostTableViewCellDelegate {
    func didPressOnUser(user: User)
    func didPressOnLikeCountLbl(users: [User])
    func didPressCommentBtn(on post: Post)
    func didGetNewInfo(on post: Post)
    func didToggleLike(on post: Post)
}

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentTableView: UITableView! {
        didSet {
            setUpCommentTableView()
        }
    }
    var delegate: PostTableViewCellDelegate?
    
    var user: User? {
        didSet {
            setUpUser()
        }
    }
    
    var post: Post? {
        didSet {
            DispatchQueue.main.async {
                self.setUpPost()
                self.commentTableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var dateLbl: UILabel!    
    @IBOutlet weak var likeBtn: UIButton!
    @IBAction func likeBtn(_ sender: UIButton) {
        toggleLike()
    }
    
    @IBOutlet weak var likeCountLbl: UILabel! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showLikers))
            likeCountLbl.isUserInteractionEnabled = true
            likeCountLbl.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    @IBAction func commentBtn(_ sender: UIButton) {
        if let delegate = delegate, let post = post {
            delegate.didPressCommentBtn(on: post)
        }
    }
    
    @IBOutlet weak var ownerLbl: UILabel! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressOnUser))
            ownerLbl.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @IBOutlet weak var ownerProfileImageView: RoundUIImageView! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressOnUser))
            ownerProfileImageView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
}


extension PostTableViewCell {
    
    private func setUpPost() {
        DispatchQueue.main.async {
            if let post = self.post {
                
                self.postImageView.image = post.image ?? UIImage(named: ImageConstants.userImagePlaceholderId)
                self.descriptionLbl.text = post.description
                self.likeCountLbl.text = String(post.likes)
                self.dateLbl.text = post.date
                
                let isLiking = post.activeUserIsLiking ?? false
                
                if isLiking {
                    self.likeBtn.setTitle("Unlike", for: .normal)
                } else {
                    self.likeBtn.setTitle("Like", for: .normal)
                }
            }
        }
    }
    
    private func setUpUser() {
        if let user = user {
            // TODO: another image
            if user.profileImage == nil {
                user.getProfileImage {
                    DispatchQueue.main.async {
                        self.ownerProfileImageView.image = self.user?.profileImage
                        if let delegate = self.delegate, let post = self.post {
                            delegate.didGetNewInfo(on: post)
                        }
                    }
                }
            }
            
            ownerProfileImageView.image = user.profileImage ?? UIImage(named: ImageConstants.userImagePlaceholderId)
            ownerLbl.text = user.username
        }
    }
    
    private func setUpCommentTableView() {
        commentTableView.allowsSelection = false
        commentTableView.delegate = self
        commentTableView.dataSource = self
    }
    
}

// MARK: TableView DataSource
extension PostTableViewCell: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let commentCell = tableView.dequeueReusableCell(withIdentifier: ID.CellIDs.commentTableViewCellID) as! CommentTableViewCell
        
        if indexPath.row < post?.comments?.count ?? 0 {
            commentCell.delegate = self
            commentCell.comment = post?.comments?[indexPath.row] // TODO: sometimes craches
        }
        commentCell.commentTxtLbl.sizeToFit()
        return commentCell
    }
    
}


// Commentcells height functions
extension PostTableViewCell {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row < post?.comments?.count ?? 0, let comment = post?.comments?[indexPath.row] {
            let usernameLblHeight = LayoutConstants.CommentCellConstants.usernameHeight
            let commentLblHeight = LayoutUtils.calculateCommentLblHeight(comment: comment, tableViewWidth: Int(tableView.frame.width))
            let constraintsHeight = LayoutConstants.CommentCellConstants.constraintsHeight
            
            let totalHeight = CGFloat(usernameLblHeight + commentLblHeight + constraintsHeight)
            
            return totalHeight
        }
        
        return 0
    }
}


extension PostTableViewCell {
    @objc private func didPressOnUser() {
        if let delegate = delegate, let user = user {
            delegate.didPressOnUser(user: user)
        }
    }
    
    @objc private func showLikers() {
        if let delegate = delegate {
            post?.getLikers(completion: { (users) in
                if let users = users {
                    DispatchQueue.main.async {
                        delegate.didPressOnLikeCountLbl(users: users)
                    }
                }
            })
        }
    }
    
    private func toggleLike() {
        post?.activeUserIsLiking?.toggle()
        if let post = post {
            LikeModel.like(post: post, completion: { (post) in
                post?.image = self.post?.image
                self.post = post
                if let delegate = self.delegate, let post = self.post {
                    delegate.didToggleLike(on: post)
                }
            })
        }
    }
}


// MARK: - CommentTableViewCellDelegate
extension PostTableViewCell: CommentTableViewCellDelegate {
    
    func didPressOnComment(user: User) {
        if let delegate = delegate {
            delegate.didPressOnUser(user: user)
        }
    }
    
}

