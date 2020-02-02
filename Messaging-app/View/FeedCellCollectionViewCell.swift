//
//  FeedCellCollectionViewCell.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/22.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import FirebaseFirestore

protocol FeedCellDelegate {
    
    func handleUsernameTapped(for cell: FeedCellCollectionViewCell)
    
    func handleOptionButtonTapped(for cell : FeedCellCollectionViewCell)
    
    func hamdleLikeButonnTapped(for cell : FeedCellCollectionViewCell, isDoucbleTap : Bool)
    
    func handlePostimageViewTapped(for cell : FeedCellCollectionViewCell, indexPath : IndexPath)
    
    func handleCommentButtontapped (for cell : FeedCellCollectionViewCell)
    
    
}

class FeedCellCollectionViewCell: UICollectionViewCell {
    
    
    var user : FUser?
    var stackView: UIStackView!
    
    var post : Post?
    
    var delegate : FeedCellDelegate?
    
    var indexPath : IndexPath!

    
    let profileImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    lazy var usernameButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("User name", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(userNameTapped), for: .touchUpInside)
        
        return button
    }()
    
    lazy var optionsButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(optionButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    lazy var postImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .darkGray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(postImageViewTapped))
        tapGesture.numberOfTouchesRequired = 1
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tapGesture)
        
        return iv
    }()
    
    //MARK: Action Button
    
    lazy var likeButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    lazy var commentButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(commentButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var messageButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let savePostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
 
        
        return label
    }()
    
    let captionLabel: UITextView = {
        let tv = UITextView()
        
        return tv
    }()
    
    let postTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.text = "2 DAYS AGO"
        return label
    }()
    
    let commentIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(usernameButton)
        usernameButton.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(optionsButton)
        optionsButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        optionsButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        configureActionButtons()
        
        addSubview(likesLabel)
        likesLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: -4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likesLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
               
    }
    
    func configureActionButtons() {
        stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, messageButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
                
        addSubview(savePostButton)
        savePostButton.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 20, height: 24)
    }
    
    func addCommentIndicatorView(toStackView stackView: UIStackView) {
        
        commentIndicatorView.isHidden = false
        
        stackView.addSubview(commentIndicatorView)
        commentIndicatorView.anchor(top: stackView.topAnchor, left: stackView.leftAnchor, bottom: nil, right: nil, paddingTop: 14, paddingLeft: 64, paddingBottom: 0, paddingRight: 0, width: 10, height: 10)
        commentIndicatorView.layer.cornerRadius = 10 / 2
    }
    
    func generateCell(post : Post, user : FUser, indexPath : IndexPath) {
        
        self.indexPath = indexPath
        self.user = user
        self.post = post

        if user.avatar != "" {
            imageFromData(pictureData: user.avatar) { (avatar) in
                profileImageView.image = avatar?.circleMasked
            }
        }

        usernameButton.setTitle(user.fullname, for: .normal)


        postImageView.loadImage(with: post.imageLink)

        captionLabel.text = post.caption

        postTimeLabel.text = post.createtionDate.timeAgoToDisplay()

        configureLike(post: post)
    }
    
    func feedGenerateCell(post : Post, reference : DocumentReference) {
        
        reference.getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            
            if snapshot.exists {
                let userDictionay = snapshot.data()!
                
                if userDictionay[kAVATAR] as! String != "" {
                    imageFromData(pictureData: userDictionay[kAVATAR] as! String) { (avatar) in
                        self.profileImageView.image = avatar?.circleMasked
                    }
                }
                
                self.usernameButton.setTitle(userDictionay[kFULLNAME] as! String, for: .normal)
            }
        }
        
        postImageView.loadImage(with: post.imageLink)
        captionLabel.text = post.caption

        postTimeLabel.text = post.createtionDate.timeAgoToDisplay()
        
        configureLike(post: post)
        
        

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLike(post : Post) {
        
        firebaseReferences(.Post).document(post.postId).addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            
            if snapshot.exists {
                let dif = snapshot.data()![kLIKE]
                self.likesLabel.text = "\(dif!) Likes"
                
                post.checkUserLiked { (liked) in
                    if liked {
                        post.didLike = true
                        self.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
                        
                    } else {
                        post.didLike = false
                        self.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                    }
                }
            }
        }
        
        
    }
    
}

//MARK: Handlers

extension FeedCellCollectionViewCell {
    
    @objc func userNameTapped() {
        delegate?.handleUsernameTapped(for: self)
    }
    
    @objc func optionButtonTapped() {
        delegate?.handleOptionButtonTapped(for: self)
    }
    
    @objc func likeButtonTapped() {
        delegate?.hamdleLikeButonnTapped(for: self, isDoucbleTap: false)
    }
    
    @objc func postImageViewTapped() {
        delegate?.handlePostimageViewTapped(for: self, indexPath: indexPath)
    }
    
    @objc func commentButtonTapped() {
        delegate?.handleCommentButtontapped(for: self)
    }
    
}
