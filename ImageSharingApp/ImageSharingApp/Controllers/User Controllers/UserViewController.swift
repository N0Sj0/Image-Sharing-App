//
//  UserViewController.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-01.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import UIKit


// TODO: make controller shorter
class UserViewController: UIViewController {
    
    var isFollowing = false
    
    var posts = [Post]() {
        didSet {
            DispatchQueue.main.async { self.postsCollectionView.reloadData() }
        }
    }
    
    var user: User? {
        didSet {
            setUp()
            getPosts()
        }
    }
    
    var belongsToActiveUser: Bool = true {
        didSet {
            if belongsToActiveUser { followEditBtn.setTitle("Edit", for: .normal) }
            else { checkFollowStatus() }
        }
    }
    
    @IBOutlet weak var profileImageRoundImageView: RoundUIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var bioLbl: UILabel!
    @IBOutlet weak var followEditBtn: UIButton!
    @IBOutlet weak var followersCountLbl: UILabel! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFollowers))
            followersCountLbl.isUserInteractionEnabled = true
            followersCountLbl.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    @IBOutlet weak var followsCountLbl: UILabel! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFollows))
            followsCountLbl.isUserInteractionEnabled = true
            followsCountLbl.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    @IBAction func followEditBtn(_ sender: UIButton) {
        if belongsToActiveUser { moveToEditView() }
        else { follow() }
    }
    @IBOutlet weak var postsCollectionView: UICollectionView! {
        didSet {
            postsCollectionView.delegate = self
            postsCollectionView.dataSource = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        checkIfBelongsToActiveUser()
        
        if belongsToActiveUser {
            user = User.activeUser
        } else {
            setUp()
        }
    }
}


// MARK: - SetUp
extension UserViewController {
    
    private func setUpProfileImage(user: User) {
        if let profileImage = user.profileImage {
            profileImageRoundImageView.image = profileImage
            self.toggleDisableView(disabled: false)
        } else {
            user.getProfileImage {
                DispatchQueue.main.async {
                    self.profileImageRoundImageView.image = user.profileImage
                    if self.belongsToActiveUser {
                        User.activeUser = user
                    }
                    self.toggleDisableView(disabled: false)
                }
            }
        }
    }
    
    private func setUpUserAttributes(user: User) {
        bioLbl.text = user.bio ?? ""
        nameLbl.text = user.fullName
        followersCountLbl.text = String(user.followersCount)
        followsCountLbl.text = String(user.followsCount)
        navigationItem.title = user.username
    }
    
    private func setUp() {
        if let user = user, view.window != nil {
            setUpUserAttributes(user: user)
            setUpProfileImage(user: user)
        }
    }
}


// MARK: - Follow
extension UserViewController {
    
    private func setFollowStatus() {
        DispatchQueue.main.async {
            if !self.isFollowing {
                self.followEditBtn.setTitle("Follow", for: .normal)
            } else {
                self.followEditBtn.setTitle("Unfollow", for: .normal)
            }
        }
    }
    
    private func checkFollowStatus() {
        guard let user = user else {return}
        FollowModel.doesFollow(user: user) { (doesFollow) in
            self.isFollowing = doesFollow
            self.setFollowStatus()
        }
    }

    private func follow() {
        if user?.username != User.activeUser?.username, let user = user {
            FollowModel.follow(user) { (updatedActiveUser) in
                if let updatedActiveUser = updatedActiveUser {
                    User.activeUser = updatedActiveUser
                    self.isFollowing.toggle()
                    self.setFollowStatus()
                }
            }
        }
    }
}

// MARK: - Posts
extension UserViewController {
    
    private func getPostImages() {
        for post in posts {
            post.getPostImage {
                if let index = self.posts.firstIndex(where: { (indexPost) -> Bool in
                    post.postImageURL == indexPost.postImageURL
                }) {
                    DispatchQueue.main.async {
                        self.posts[index] = post
                        self.postsCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                }
            }
        }
    }
    
   private func getPosts() {
        guard let user = user, let activeUser = User.activeUser else {return}
        Post.getPosts(from: user, user: activeUser) { (posts) in
            if let posts = posts {
                self.posts = posts
                self.getPostImages()
            } 
        }
    }
    
}


// MARK: - CollectionView DataSource and Delegate
extension UserViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let postCell = collectionView.dequeueReusableCell(withReuseIdentifier: ID.CellIDs.postCollectionViewCellID, for: indexPath) as! PostCollectionViewCell
        
        postCell.postImageView.image = posts[indexPath.row].image ?? UIImage(named: ImageConstants.userImagePlaceholderId)
        
        return postCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let postsTableViewController = storyboard?.instantiateViewController(withIdentifier: ID.ControllerIDs.postTableViewControllerID) as! FeedTableViewController
        
        postsTableViewController.isUserFeed = false
        postsTableViewController.posts = [posts[indexPath.row]]
        navigationController?.pushViewController(postsTableViewController, animated: true)
    }
    
}


// MARK: - Follow and Followers
extension UserViewController {
    
    private func moveToUsersView(with users: [User]) {
        let usersTableViewController = storyboard?.instantiateViewController(withIdentifier: ID.ControllerIDs.usersTableViewControllerID) as! UsersTableViewController
        
        usersTableViewController.users = users
        navigationController?.pushViewController(usersTableViewController, animated: true)
    }
    
    @objc private func showFollows() {
        if let user = user {
            FollowModel.getFollows(from: user.username) { (follows) in
                if let follows = follows {
                    DispatchQueue.main.async {
                        user.follows = follows
                        self.moveToUsersView(with: follows)
                    }
                }
            }
        }
    }
    
    @objc private func showFollowers() {
        if let user = user {
            FollowModel.getFollowers(from: user.username) { (followers) in
                if let followers = followers {
                    DispatchQueue.main.async {
                        user.followers = followers
                        self.moveToUsersView(with: followers)
                    }
                }
            }
        }
    }
}


// MARK: - Utils
extension UserViewController {
    private func checkIfBelongsToActiveUser() {
        if let user = user, let activeUser = User.activeUser, user.username == activeUser.username {
            belongsToActiveUser = true
        } else {
            belongsToActiveUser = false
        }
    }
    
   private func moveToEditView() {
        if let editUserTableViewController = storyboard?.instantiateViewController(withIdentifier: ID.ControllerIDs.editUserTableViewControllerID) as? EditUserTableViewController {
            navigationController?.pushViewController(editUserTableViewController, animated: true)
        }
    }
    
    func toggleDisableView(disabled: Bool) {
        bioLbl.alpha = disabled ? 0.5 : 1
        nameLbl.alpha = disabled ? 0.5 : 1
        profileImageRoundImageView.alpha = disabled ? 0.5 : 1
    }
}
