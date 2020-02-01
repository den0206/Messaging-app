//
//  ProfileCollectionViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/24.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class ProfileCollectionViewController: UICollectionViewController,  UICollectionViewDelegateFlowLayout{
    
    var user : FUser?
    var posts = [Post]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)

        collectionView?.backgroundColor = .white
     
        configureRefreshController()
        
      
        
        if user != nil {
            fetchPosts()
        }
        
       
    }
    
    //MARK: Flowlayout
    // headerSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    // cell Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }

    
    // spacimg
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
          return 1
      }
      
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 1
      }
      

    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
        
        var post : Post
        post = posts[indexPath.row]
        
        cell.generateCell(post: post)
   
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let feedVC = FeedCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        feedVC.singleViewPost = true
        feedVC.post = posts[indexPath.row]
        
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
               
        header.user = user
        navigationItem.title = user?.fullname
        
        if user != nil {
            header.generateCell(user: user!, indexPath: indexPath)
            
        }
        header.delegate = self
        
        setUserStatus(header: header)
        
        return header
    }
    
  
    
    //MARK: FetchPosts
    
    private func fetchPosts() {
        
        firebaseReferences(.Post).whereField(kUSERID, isEqualTo: user!.objectId).order(by: kCREATEDAT, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            self.collectionView.refreshControl?.endRefreshing()
            
            if !snapshot.isEmpty {
                for doc in snapshot.documents {
                    let postDictionary = doc.data() as NSDictionary
                    
                    // Post initialize
                    let post = Post(_user: self.user!, dictionary: postDictionary)
                    self.posts.append(post)
                    
                    
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK:
    
    private func configureRefreshController () {
        let rehreshController = UIRefreshControl()
        rehreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = rehreshController
        
    }
    
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: true)
        fetchPosts()
        collectionView.reloadData()
    }
    
}

extension ProfileCollectionViewController : UserProfileHeaderDelegate {
  
    
    
    func setUserStatus(header: UserProfileHeader) {
        
        guard let userId = header.user?.objectId else {return}
        
        var numberOfFollwers: Int!
        var numberOfFollowing: Int!
        
        
        // Following Lable
        
        firebaseReferences(.User).document(userId).getDocument { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            if snapshot.exists {
                numberOfFollowing = snapshot.data()?[kUSERFOLLOWING] as? Int
            } else {
                numberOfFollowing = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing ?? 0)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "followings", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.followingLabel.attributedText = attributedText
        }
        
        // Followers Label
        
        firebaseReferences(.User).document(userId).getDocument { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            if snapshot.exists {
                numberOfFollwers = snapshot.data()?[kUSERFOLOWERS] as? Int
            } else {
                numberOfFollwers = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollwers ?? 0)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.followersLabel.attributedText = attributedText
        }
        

        
        // Post Label

        firebaseReferences(.Post).whereField(kUSERID, isEqualTo: user!.objectId).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot?.documents else {return}
            
            let postNumber = snapshot.count
            
            let attributedText = NSMutableAttributedString(string: "\(postNumber)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "post", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.postLabel.attributedText = attributedText
        }
        
        //        firebaseReferences(.Post).document(userId).collection(kPOST).getDocuments { (snapshot, error) in
        //
        //
                //        }
    }
    
    
    func handleEditProfileEdit(header: UserProfileHeader) {
        
        if user?.objectId == FUser.currentID() {
            // go edit
            
            let editVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditVC") as! EditUserViewController
            
            navigationController?.pushViewController(editVC, animated: true)
        } else {
            // follow Section
            
            if header.editProfileFollowButton.titleLabel?.text == "Follow" {
                 header.editProfileFollowButton.setTitle("Following", for: .normal)
                user?.follow()
            } else {
                header.editProfileFollowButton.setTitle("Follow", for: .normal)
                user?.unFollow()
            }
            
        }
    }
    
    func followerTapped(header: UserProfileHeader) {
         let followerVC = FollowLikeViewController()
        followerVC.viewingMode = .Follwers
        followerVC.user = self.user
        
        navigationController?.pushViewController(followerVC, animated: true)
      }
      
      func followingTapped(header: UserProfileHeader) {
          
        let followingVC = FollowLikeViewController()
        followingVC.viewingMode = .Following
        followingVC.user = self.user
        
        navigationController?.pushViewController(followingVC, animated: true)
      }
      

    
}
