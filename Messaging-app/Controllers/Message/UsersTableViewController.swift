//
//  UsersTableViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/17.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase

class UsersTableViewController: UITableViewController {
    
    var allUsers : [FUser] = []
    var filterUsers : [FUser] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var activityIndicator : NVActivityIndicatorView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Users"
        tableView.tableFooterView = UIView()
        
        configureSearchController()
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: tableView.frame.width / 2 - 30, y: tableView.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballPulse, color: #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), padding: nil)
        
        loadUsers()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = cancelButton
        
        
    }
    

    // MARK: - Table view data source

   

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if searchController.isActive  && searchController.searchBar.text != "" {
            return filterUsers.count
        }
        return allUsers.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersTableViewCell
        let user : FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filterUsers[indexPath.row]
        } else {
            user = allUsers[indexPath.row]
        }
        
        cell.delegate = self
        
        cell.generateCell(fUser: user, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var user : FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filterUsers[indexPath.row]
        } else {
            user = allUsers[indexPath.row]
        }
        
        if !checkBlockedtatus(withUser: user) {
            let messageVC = MessageViewController()
            messageVC.chatRoomId =  startPrivateChat(user1: FUser.currentUser()!, user2: user)
            messageVC.membersToPush = [FUser.currentID(), user.objectId]
            messageVC.memberIds = [FUser.currentID(), user.objectId]
            messageVC.isGrouped = false
            
            navigationController?.pushViewController(messageVC, animated: true)
        }
        
        
    }
    
   
    
    //MARK: LoadUsers
    
    private func loadUsers() {
        
        startIndicator()
        
        // All users
        
        var query : Query!
        
        query = firebaseReferences(.User).order(by: kFISRSTNAME, descending: false)
        
        query.getDocuments { (snapshot, error) in
            
            if error != nil {
                print("\(error?.localizedDescription)")
                self.hideIndicator()
                self.tableView.reloadData()
                return
            }
            
            // no error
            guard let snapshot = snapshot else {
                self.hideIndicator()
                return
            }
            
            if !snapshot.isEmpty {
               
                for userDictionary in snapshot.documents {
                    let userDictionary = userDictionary.data() as NSDictionary
                    let user = FUser(_dictionary: userDictionary)
                    
                    if user.objectId != FUser.currentID() {
                        self.allUsers.append(user)
                    }
                }
                
               // split Data
            }
            
            self.tableView.reloadData()
            self.hideIndicator()
            print(self.allUsers.count)
            
        }
        
    }
    
    //MARK: Helpers
    
    
    @objc func cancel() {
        
        navigationController?.popViewController(animated: true)
    }
    
    private func startIndicator() {
        
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator?.startAnimating()
        }
    }
    
    private func hideIndicator() {
        
        if activityIndicator != nil {
            activityIndicator?.removeFromSuperview()
            activityIndicator?.stopAnimating()
        }
    }
    
    func checkBlockedtatus(withUser : FUser) -> Bool {
        return withUser.blockedUsers.contains(FUser.currentID())
    }
    
    
    
    
}

    //MARK: Search Controller && usersCellDelegate


extension UsersTableViewController : UISearchResultsUpdating, UserstableViewCellDelegate {
    
    func avatartapped(indexPath: IndexPath) {
        var user : FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user  = filterUsers[indexPath.row]
        } else {
            user = allUsers[indexPath.row]
        }
        showProfile(fuser: user, indexpath: indexPath)
        
    }
    
    private func showProfile(fuser : FUser, indexpath :IndexPath) {
        
//        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileVC") as! ProfileTableViewController
//
//        profileVC.user = fuser
//
//        navigationController?.pushViewController(profileVC, animated: true)
        
        let profileVC = ProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        profileVC.user = fuser
        navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    
    private func configureSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    private func filterContentForSearch(searchText : String) {
        
        filterUsers = allUsers.filter({ (user) -> Bool in
            return user.firstName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchText: searchController.searchBar.text!)
        
    }
    
    
}
