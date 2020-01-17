//
//  RexentsTableViewCell.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/17.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class RecentsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.contentMode = .scaleAspectFit
            avatarImageView.clipsToBounds = true
            
        }
    }
    
    @IBOutlet weak var fullNameLabel: UILabel! {
        didSet {
            fullNameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        
        }
    }
    
    @IBOutlet weak var lastMessageLabel: UILabel! {
        didSet {
            lastMessageLabel.font = UIFont.systemFont(ofSize: 12)
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel! {
        didSet {
            dateLabel.font = UIFont.systemFont(ofSize: 12)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        avatarImageView.layer.cornerRadius = 50 / 2
        avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
         fullNameLabel.anchor(top: avatarImageView.topAnchor, left: avatarImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
          lastMessageLabel.anchor(top: fullNameLabel.bottomAnchor, left: avatarImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 6, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        dateLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
               dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
       
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    
   

}
