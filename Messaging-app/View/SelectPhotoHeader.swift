//
//  SelectPhotoCollectionViewCell.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/22.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class SelectPhotoHeader: UICollectionViewCell {
    
    let photoImageView : UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
