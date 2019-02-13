//
//  FeedTableViewController.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-16.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController {
    
    
    var posts = [Post]()
    var owners = [String:User]()
    var ownerPostIndexes = [String: [Int]]()
    
    var isUserFeed = true
    
    var isGettingData = false
    var gotAllData = false
    
    var loadedOwners = 0
    var loadedPosts = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        scrollToTop()
        if posts.count == 0 {
            getInitialData()
        }
    }
}


// MARK: - Feed
extension FeedTableViewController {
    
    @objc private func getInitialData() {
        if isUserFeed, !isGettingData {
            gotAllData = false
            loadedOwners = 0
            loadedPosts = 0
            posts = []
            owners = [:]
            ownerPostIndexes = [:]
            tableView.reloadData()
            getFeedData(initialRequest: true)
        } else {
            checkIfFinishedLoadingData(loadedPosts: loadedPosts, loadedOwners: loadedOwners)
        }
    }
    
    @objc private func getMorePosts() {
        if !isGettingData {
            getFeedData(initialRequest: false)
        }
    }
    
    private func checkIfFinishedLoadingData(loadedPosts: Int, loadedOwners: Int) {
        
        if !(loadedPosts % Post.maxPostsPerRequest == 0 || loadedPosts < Post.maxPostsPerRequest) {
            gotAllData = true
        }
        
        if loadedPosts == posts.count, loadedOwners == owners.count {
            self.isGettingData = false
            self.refreshControl?.endRefreshing()
            if self.refreshControl == nil {
                self.enableRefreshControl()
            }
        }
    }
    
    private func mergeOwners(newOwners: [String:User]) {
        for (username, newOwner) in newOwners {
            if owners[username] == nil {
                owners[username] = newOwner
            }
        }
    }
    
    private func getFeedData(initialRequest: Bool) {
        // starting to fetch data
        isGettingData = true
        
        Feed.getFeed(num: posts.count) { (owners, posts) in
            guard let posts = posts, let owners = owners, posts.count != 0, owners.count != 0 else {return}
            self.mergeOwners(newOwners: owners)
            
            DispatchQueue.main.async {
                if initialRequest {
                    self.posts += posts
                    self.tableView.reloadData()
                }
                
                // For every new post, set its owner, get image and display it
                var postIndex = max(posts.count - 1, 0)
                for post in posts {
                    if let owner = self.owners[post.owner.username] { post.owner = owner }
                    self.ownerPostIndexes[post.owner.username]?.append(postIndex)
                    if !initialRequest {
                        self.posts.append(post)
                        self.tableView.insertRows(at: [IndexPath(item: self.tableView.numberOfRows(inSection: 0), section: 0)], with: .fade)
                    }
                    post.getPostImage {
                        self.updateTableViewPost(from: post)
                    }
                    postIndex += 1
                }
                
                for (username,  owner) in owners {
                    // TODO: Maybe just check the profileImage url
                    if self.owners[username]?.profileImage == nil {
                        owner.getProfileImage {
                            self.updateTableViewUser(with: owner)
                        }
                    }
                }
            }
        }
    }
}


// MARK: - TableView datasource
extension FeedTableViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= posts.count - LayoutConstants.postsLeftBeforeLoadingMore, isUserFeed {
            getMorePosts()
        }
    }
    
    private func calculateHeightForRowAt(index: Int) -> CGFloat{
        let labelHeight = LayoutConstants.FeedCellConstants.calculateLblHeight(descriptionCount: posts[index].description.count, labelWidth: Double(view.frame.width))
        let commentsHeight = LayoutConstants.FeedCellConstants.calculateCommentsHeight(commentsCount: posts[index].comments?.count ?? 0)
        let imageHeight = Int(view.frame.width)
        let otherViews = LayoutConstants.FeedCellConstants.utilsHeight + LayoutConstants.FeedCellConstants.constraintsHeight + LayoutConstants.FeedCellConstants.profileImageHeight
        
        let total = labelHeight + commentsHeight + imageHeight + otherViews
        
        return CGFloat(total)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateHeightForRowAt(index: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateHeightForRowAt(index: indexPath.row
        )
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let postCell = tableView.dequeueReusableCell(withIdentifier: ID.CellIDs.postTableViewCellID, for: indexPath) as! PostTableViewCell
        
        postCell.delegate = self
        let post = posts[indexPath.row]
        let owner = post.owner
        
        postCell.post = post
        postCell.user = owner
        
        return postCell
    }
}

// MARK: - PostTableViewCellDelegate
extension FeedTableViewController: PostTableViewCellDelegate {
    
    func didToggleLike(on post: Post) {
        if let index = posts.firstIndex(where: { (secondPost) -> Bool in
            secondPost.id == post.id && secondPost.owner.username == post.owner.username
        }) {
            posts[index] = post
        }
    }
    
    func didGetNewInfo(on post: Post) {
        if let index = posts.firstIndex(where: { (secondPost) -> Bool in
            secondPost.id == post.id && secondPost.owner.username == post.owner.username
        }) {
            tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .none)
        }
    }
    
    func didPressCommentBtn(on post: Post) {
        showCommentAlert(post: post)
    }
    
    func didPressOnLikeCountLbl(users: [User]) {
        presentLikers(with: users)
    }
    
    func didPressOnUser(user: User) {
        presentUserView(with: user)
    }
    
    private func presentLikers(with users: [User]) {
        let usersTableViewController = storyboard?.instantiateViewController(withIdentifier: ID.ControllerIDs.usersTableViewControllerID) as! UsersTableViewController
        usersTableViewController.users = users
        
        navigationController?.pushViewController(usersTableViewController, animated: true)
    }
    
    private func presentUserView(with user: User) {
        let userViewController = storyboard?.instantiateViewController(withIdentifier: ID.ControllerIDs.userViewControllerId) as! UserViewController
        userViewController.user = user
        navigationController?.pushViewController(userViewController, animated: true)
    }
}

// MARK: Comment functions
extension FeedTableViewController {
    
    func showCommentAlert(post: Post) {
        let alert = Alerts.createCommentAlert { (commentText) in
            if let commentText = commentText {
                self.comment(with: commentText, on: post)
            }
        }
        present(alert, animated: true, completion: nil)
    }
    
    func comment(with comment: String?, on post: Post) {
        if(comment == "") {return}
        guard let comment = comment, let activeUser = User.activeUser else {return}
        Comment.comment(post: post, with: comment) { (success) in
            if !success {return}
            
            guard let index = self.posts.firstIndex(where: { (secondPost) -> Bool in
                return secondPost.id == post.id && secondPost.owner.username == post.owner.username
            }) else {return}
            
            DispatchQueue.main.async {
                self.posts[index].comments?.append(Comment(text: comment, ownerString: activeUser.username))
                self.tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .fade)
            }
        }
    }
}

// MARK: - Utilities
extension FeedTableViewController {
    
    private func updateTableViewPost(from post: Post) {
        DispatchQueue.main.async {
            if let postIndex  = self.posts.firstIndex(where: { (indexPost) -> Bool in
                indexPost.postImageURL == post.postImageURL
            }) {
                let postIndexPath = IndexPath(item: postIndex, section: 0)
                self.tableView.reloadRows(at: [postIndexPath], with: .none)
                self.loadedPosts+=1
            }
            self.checkIfFinishedLoadingData(loadedPosts: self.loadedPosts, loadedOwners: self.loadedOwners)
        }
    }
    
    private func updateTableViewUser(with user: User) {
        DispatchQueue.main.async {
            self.owners[user.username] = user
            
            for index in self.ownerPostIndexes[user.username] ?? [] {
                let indexPath = IndexPath(item: index, section: 0)
                self.posts[index].owner = user
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
            self.loadedOwners += 1
            self.checkIfFinishedLoadingData(loadedPosts: self.loadedPosts, loadedOwners: self.loadedOwners)
        }
    }
    
    
    private func scrollToTop() {
        let indexPath = IndexPath(item: 0, section: 0)
        
        if posts.count != 0 {
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}

// MARK - RefreshControl functions
extension FeedTableViewController {
    
    private func enableRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getInitialData), for: .valueChanged)
        
        tableView.addSubview(refreshControl)
        self.refreshControl = refreshControl
    }

}
