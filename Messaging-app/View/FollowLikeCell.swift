//
//  FollowLikeCell.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/30.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

protocol FollowLikeCellDelegate {
    func handleFoLLowtapped(cell : FollowLikeCell)
}


class FollowLikeCell: UITableViewCell {
    
    var user : FUser?
    var delegate : FollowLikeCellDelegate?
    
    //MARK: Parts
    
    
    let profileImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    lazy var followButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func followButtonTapped() {
           delegate?.handleFoLLowtapped(cell: self)
       }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2
        
        addSubview(followButton)
        followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
        followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        followButton.layer.cornerRadius = 3
        
        
        textLabel?.text = "UserName"
        detailTextLabel?.text = "FUllname"
        
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y, width: self.frame.width - 108, height: detailTextLabel!.frame.height)
        detailTextLabel?.textColor = .lightGray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    
    func generateCell() {
        guard let user = self.user else {return}
        
        if user.avatar != "" {
            imageFromData(pictureData: user.avatar) { (avatar) in
                profileImageView.image = avatar?.circleMasked
            }
        }
        
        textLabel?.text = user.firstName
        detailTextLabel?.text = user.fullname
        
        user.chackUserFollowed { (followed) in
            if followed {
                self.followButton.configure(didFollow: true)
            } else {
                self.followButton.configure(didFollow: false)
            }
        }
    }
    
    
    
   
}
