//
//  SearchTableViewController.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2019-02-07.
//  Copyright © 2019 Noah Sjöberg. All rights reserved.
//

import UIKit

class SearchTableViewController: UsersTableViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    func setUpSearchBar() {
        searchBar.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchBar()
    }
    
}


// MARK: - SearchBarDelegate
extension SearchTableViewController: UISearchBarDelegate {
    
    private func updateTableViewWithUser(user: User) {
        DispatchQueue.main.async {
            guard let index = self.users.firstIndex(where: { (secondUser) -> Bool in
                user.username == secondUser.username
            }) else { return }
            self.tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .fade)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        SearchModel.searchForUser(with: searchText) { (newUsers) in
            let oldUsers = self.users
            self.users = []
            
            DispatchQueue.main.async {
                // check to make sure the current searchBarText is equal to the text that was search
                if searchText != searchBar.text ?? "" {self.tableView.reloadData(); return}
                
                for user in newUsers ?? [] {
                    var isFound = false
                    for oldUser in oldUsers {
                        if user.username == oldUser.username {
                            self.users.append(oldUser)
                            isFound = true
                            break
                        }
                    }
                    if !isFound {
                        self.users.append(user)
                    }
                }
                self.tableView.reloadData()
                for user in self.users {
                    if user.profileImage == nil {
                        user.getProfileImage {
                            self.updateTableViewWithUser(user: user)
                        }
                    }
                }
            }// Dispatchqueue
        } // search
    } // delegate
} // extension
