//
//  CommentCell.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/02/02.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment : Comment?
    
    let profileImageView: CustomImageView = {
           let iv = CustomImageView()
           iv.contentMode = .scaleAspectFill
           iv.clipsToBounds = true
           iv.backgroundColor = .lightGray
           return iv
       }()
    
    let nameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    let commentLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    let createdAtLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        
        addSubview(commentLabel)
        commentLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        
        addSubview(createdAtLabel)
        createdAtLabel.anchor(top: topAnchor, left: commentLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 24, width: 0, height: 0)
    }
    
    func generateCell(user : FUser, comment : Comment) {
        self.comment = comment
        
        guard let commentText = comment.commentText else {return}
        guard let createdAt = getCommentTimeStamp() else {return}
        
        self.nameLabel.text = user.firstName
        self.commentLabel.text = commentText
        self.createdAtLabel.text = createdAt
        
        if user.avatar != "" {
            imageFromData(pictureData: user.avatar) { (avatar) in
                profileImageView.image = avatar
            }
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getCommentTimeStamp() -> String? {
           
           guard let comment = self.comment else { return nil }
           
           let dateFormatter = DateComponentsFormatter()
           dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
           dateFormatter.maximumUnitCount = 1
           dateFormatter.unitsStyle = .abbreviated
           let now = Date()
           return dateFormatter.string(from: comment.creationDate, to: now)
       }
    
    
}
