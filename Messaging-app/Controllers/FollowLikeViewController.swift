//
//  FollowLikeViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/30.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class FollowLikeViewController: UITableViewController {
    
    enum viewMode {
        
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: "Cell")

     
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

  
}
