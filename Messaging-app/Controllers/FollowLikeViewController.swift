//
//  FollowLikeViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/30.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import FirebaseFirestore

class FollowLikeViewController: UITableViewController, FollowLikeCellDelegate {
    
    enum viewingMode {
        
        case Following
        case Follwers
        case Likes
        
        init(index : Int) {
            switch index {
            case 0: self = .Following
            case 1 : self = .Follwers
            case 2 : self = .Likes
            default: self = .Following
            }
        }
        
    }
    
    var viewingMode : viewingMode!
    
    var user : FUser?
    var users = [FUser]()
    var relationIds : [String] = []
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: "Cell")
        
        configureTitle()
        
        fetchUsers()
        
        tableView.separatorColor = .clear

     
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowLikeCell
        
        cell.delegate = self
        
        let user = users[indexPath.row]
        
        cell.user = user
        cell.generateCell()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func configureTitle() {
        
        guard let viewingMode = self.viewingMode else {return}
        
        switch viewingMode {
        case .Follwers:
            self.title = "Followers"
        case .Following :
            self.title = "Folling"
        case .Likes :
            self.title = "Like"
            
        }
        
    }
    
    private func getDatebaseReference(userObject : FUser?) -> CollectionReference? {
        guard let viewingMode = self.viewingMode else {return nil}
        
        switch viewingMode {
            // from Profile
        case .Following: return userFollowingReference(userObject!.objectId)
        case .Follwers : return userFolloweredReference(userObject!.objectId)
            // Post
        case .Likes : return nil
        }
    }
    
    //MARK: FetchUsers
    
    private func fetchUsers() {
        guard let followLikeRef = getDatebaseReference(userObject: self.user) else {return}
        guard let viewingMode = self.viewingMode else {return}
        
        switch viewingMode {
            
        //MARK: ReletionshipUsers
        case .Following , .Follwers:
            // get RelationIds
            
            followLikeRef.getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {return}
                
                if !snapshot.isEmpty {
                    // get RelationIds
                    snapshot.documents.forEach { (snapshot) in
                        let relationId = snapshot.documentID
                        self.relationIds.append(relationId)
                    }
                    
                    // get UserObject
                    firebaseReferences(.User).whereField(kOBJECTID, in: self.relationIds).getDocuments { (snapshot, error) in
                        guard let snapshot = snapshot else {return}
                        if !snapshot.isEmpty {
                            for doc in snapshot.documents {
                                let userDictionary = doc.data() as NSDictionary
                                let user = FUser(_dictionary: userDictionary)
                                self.users.append(user)
                                
                            }
                            self.tableView.reloadData()
                            
                        }
                    }
                    
                }
            }
            
            
        //MARK: LikeUsers
        case .Likes:
            return
        }
    }
    
    //MARK: Handle Area
    
    func handleFoLLowtapped(cell: FollowLikeCell) {
        guard let user = cell.user else {return}
        
        user.chackUserFollowed { (follwed) in
            if follwed {
                user.unFollow()
                
                // configure follow button for non followed user
                cell.followButton.setTitle("Follow", for: .normal)
                cell.followButton.setTitleColor(.white, for: .normal)
                cell.followButton.layer.borderWidth = 0
                cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            } else {
                user.follow()
                
                // configure follow button for followed user
                cell.followButton.setTitle("Following", for: .normal)
                cell.followButton.setTitleColor(.black, for: .normal)
                cell.followButton.layer.borderWidth = 0.5
                cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
                cell.followButton.backgroundColor = .white
            }
        }
    }
    
    
}

