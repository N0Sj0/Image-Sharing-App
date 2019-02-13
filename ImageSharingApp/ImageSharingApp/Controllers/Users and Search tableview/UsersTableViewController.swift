//
//  SearchTableViewController.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2018-11-13.
//  Copyright © 2018 Noah Sjöberg. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserProfilePictures()
    }    
}

extension UsersTableViewController {
    
    private func getUserProfilePictures() {
        for user in users {
            user.getProfileImage {
                DispatchQueue.main.async {
                if let index = self.users.firstIndex(where: { (secondUser) -> Bool in
                    user.username == secondUser.username
                }) {
                    self.tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .none)
                }
                }
            }
        }
    }
    
    private func moveToUserView(user: User) {
        let userView = storyboard?.instantiateViewController(withIdentifier: ID.ControllerIDs.userViewControllerId) as! UserViewController
        userView.user = user
        userView.belongsToActiveUser = false
        navigationController?.pushViewController(userView, animated: true)
    }
    
}

// MARK: - TableView DataSource
extension UsersTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moveToUserView(user: users[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ID.CellIDs.userTableViewCellID, for: indexPath) as! UserTableViewCell
        
        cell.profileImageView?.image = users[indexPath.row].profileImage ?? UIImage(named: ImageConstants.userImagePlaceholderId)
        cell.usernameLbl.text = users[indexPath.row].username
        
        return cell
    }
    
}




