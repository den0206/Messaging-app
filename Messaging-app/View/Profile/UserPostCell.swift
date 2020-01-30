//
//  UserPostCell.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/24.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class UserPostCell: UICollectionViewCell {
    
    
    
    let postImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(postImageView)
        postImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func generateCell(post : Post) {
        
        if post.imageLink != "" {
            postImageView.image = downLoadImage(imageLink: post.imageLink)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
