//
//  UserProfileHeader.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/24.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class UserProfileHeader: UICollectionViewCell {
    
    var user : FUser?
    var indexPath : IndexPath?
    
    //MARK: Parts
    
    let profileImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv .backgroundColor = .lightGray
        return iv
    }()
    
    let nameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let postLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        return label
    }()
    
    lazy var followersLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        
        return label
    }()
    
    lazy var followingLabel : UILabel  = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        
//        // add gesture recognizer
//        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
//        followTap.numberOfTapsRequired = 1
//        label.isUserInteractionEnabled = true
//        label.addGestureRecognizer(followTap)
        return label
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
//        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return button
    }()
    
    let gridButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        return button
    }()
    
    let listButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let bookmarkButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
      addSubview(profileImageView)
      profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
      profileImageView.layer.cornerRadius = 80 / 2
      
      addSubview(nameLabel)
      nameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
      
      configureStatusLabel()
      
      addSubview(editProfileFollowButton)
      editProfileFollowButton.anchor(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: 0, height: 30)
      
      
        configureBottomToolBar()
    }
    
    func configureStatusLabel() {
        
        let stackView = UIStackView(arrangedSubviews: [postLabel,followersLabel,followingLabel])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    func configureBottomToolBar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    func generateCell(user : FUser, indexPath : IndexPath) {
        self.indexPath = indexPath
        self.nameLabel.text = user.fullname
        
        if user.avatar != "" {
            imageFromData(pictureData: user.avatar) { (avatar) in
                profileImageView.image = avatar?.circleMasked
            }
        }
        
        if user.objectId == FUser.currentID() {
            print("current")
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}


