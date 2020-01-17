//
//  UsersTableViewCell.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/17.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel! {
        didSet {
            fullNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        }
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        avatarImageView.layer.cornerRadius = 50 / 2
        avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        fullNameLabel.anchor(top: nil, left: avatarImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        fullNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
