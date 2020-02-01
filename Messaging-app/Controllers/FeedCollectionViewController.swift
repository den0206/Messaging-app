//
//  FeedCollectionViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/22.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import FirebaseFirestore

private let reuseIdentifier = "Cell"

class FeedCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout,FeedCellDelegate {
   
    
 
    var posts = [Post]()
    var post : Post?
    var singleViewPost = false
    var lastDocument : DocumentSnapshot? = nil
    
    let followingRef = userFollowingReference(FUser.currentID())
    var followingIDs = [FUser.currentID()]
    
    var followingListner : ListenerRegistration?
    
    deinit {
        followingListner?.remove()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()

        self.collectionView!.register(FeedCellCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        configureButton_Refresh()
        
        
        if !singleViewPost {
            getFollowing()
            fetchPost()
        }
        
        
      
    }
    
    //MARK: Flowlayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 50
        height += 60
        
        return CGSize(width: width, height: height)
    }
    
    

 

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1

    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if singleViewPost {
            return 1
        } else {
            return posts.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count >= 5 && indexPath.item == (self.posts.count - 1) {
            fetchMorePosts()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCellCollectionViewCell
        
        cell.delegate = self
        
        if singleViewPost {
            if let post = self.post {
                if post.user != nil {
                    // From Profile
                    cell.generateCell(post: post, user: post.user!, indexPath: indexPath)
                } else {
                    fetchUserIDinFiresore(post.userId) { (user) in
                        cell.generateCell(post: post, user: user, indexPath: indexPath)
                    }
                }
            
            }
        } else {
            
            let post = posts[indexPath.item]
            
            fetchUserIDinFiresore(post.userId) { (user) in
                cell.generateCell(post: post, user: user, indexPath: indexPath)
            }
                        
        }

    
        return cell
    }
    
    @objc func showUploadPostVC() {
        let selectVC = SelectImageCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        navigationController?.pushViewController(selectVC, animated: true)
    }
    
    private func configureButton_Refresh() {
        
        collectionView?.backgroundColor = .white
        
        self.title = "Feed"
        
        let refreshController = UIRefreshControl()
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshController
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(showUploadPostVC))
        navigationItem.rightBarButtonItem = rightButton
        
        
    }
    
    //MARK: Refresh
       @objc func handleRefresh() {
           //handle refresh
        self.posts.removeAll(keepingCapacity: false)
       
        
        if !singleViewPost {
            
            fetchPost()
        } else {
            collectionView.refreshControl?.endRefreshing()
        }
        
        collectionView.reloadData()
           
       }
    
    //MARK: get followings
    
    func getFollowing() {
        
        followingListner = followingRef.addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else {return}
            
            if !snapshot.isEmpty {
                
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        
                        let followingId = diff.document.documentID
                        self.followingIDs.append(followingId)
                    }
                    
                    if (diff.type == .removed) {
                        let unFollowingId = diff.document.documentID
                        self.followingIDs.remove(at: self.followingIDs.firstIndex(of: unFollowingId)!)
                    }
                }
                
            } else {
                // no document init
                self.followingIDs = [FUser.currentID()]
            }
            
        })
        
        
    }
    
    
    //MARK: fetchPost
    
    private func fetchPost() {
       
        
        firebaseReferences(.Post).whereField(kUSERID, in: followingIDs).order(by: kCREATEDAT, descending: true).limit(to: 5).getDocuments { (snapshot, error) in
            
            
            guard let snapshot = snapshot else {return}
            self.collectionView.refreshControl?.endRefreshing()
            
            if !snapshot.isEmpty {
                for doc in snapshot.documents {
                    let postDictionary = doc.data() as NSDictionary
                    
                    let post = Post(_reference: postDictionary[kUSERREFERENCE] as! DocumentReference, dictionary: postDictionary)
 
                    
                    self.posts.append(post)
     
                }
                
                print(self.posts.count, self.followingIDs.count)
                self.lastDocument = snapshot.documents.last
                self.collectionView.reloadData()
            }
        }
        
        

    }
    
    private func fetchMorePosts() {
        
        guard let lastDocument = lastDocument else {return}
            
            firebaseReferences(.Post).whereField(kUSERID, in: self.followingIDs).order(by: kCREATEDAT, descending: true).start(afterDocument: lastDocument).limit(to: 5).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {return}
                
                
                if !snapshot.isEmpty {
                    for doc in snapshot.documents {
                        let postDictionary = doc.data() as NSDictionary
                        
                        let post = Post(_reference: postDictionary[kUSERREFERENCE] as! DocumentReference, dictionary: postDictionary)
                        self.posts.append(post)
                        
                        
                    }
                    print(self.posts.count, self.followingIDs.count)
                    self.lastDocument = snapshot.documents.last
                    self.collectionView.reloadData()
                }
            }
  
    }
    
    private func syncUser(userid : String) -> FUser? {
           let semaphore = DispatchSemaphore(value: 0)
           var resultUser : FUser?
           
           fetchUserIDinFiresore(userid) { (user) in
               resultUser = user
               semaphore.signal()
           }
           semaphore.wait()
           return resultUser
       }
       

}

//MARK: Cell handlers


extension FeedCollectionViewController {
    
    func handleUsernameTapped(for cell: FeedCellCollectionViewCell) {
        let profileVC = ProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        profileVC.user = cell.user
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func handleOptionButtonTapped(for cell: FeedCellCollectionViewCell) {
        guard let post = cell.post else {return}
        
        
        if post.userId == FUser.currentID() {
            //MARK: Delete Action
            let alertController = UIAlertController(title: "Option", message: nil, preferredStyle: .actionSheet)
            
            //MARK: Delete
            alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { (_) in
                
                // delete From Storoge
                post.deletePost(post: post)
                
                if !self.singleViewPost {
                    self.handleRefresh()
                }
                
            }))
            
            //MARK: Eidt Action
            alertController.addAction(UIAlertAction(title: "Edit Post", style: .default, handler: { (_) in
                print("Edit")
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func handlePostimageViewTapped(for cell: FeedCellCollectionViewCell, indexPath: IndexPath) {
        // single View mode
        
        if !singleViewPost {
            
            let singleFeedVC = FeedCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
            singleFeedVC.singleViewPost = true
            singleFeedVC.post = posts[indexPath.item]
            
            navigationController?.pushViewController(singleFeedVC, animated: true)
        }
        
    }
    
  
    
    func hamdleLikeButonnTapped(for cell: FeedCellCollectionViewCell, isDoucbleTap: Bool) {
        
        print("Like")
    }
    
    
  


}



