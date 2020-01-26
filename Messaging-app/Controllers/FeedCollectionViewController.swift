//
//  FeedCollectionViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/22.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var posts = [Post]()
    var post : Post?
    var singleViewPost = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()

        self.collectionView!.register(FeedCellCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        configureButton_Refresh()
        
        if !singleViewPost {
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
    
//    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if posts.count > 4 {
//            if indexPath.item == posts.count - 1 {
//                fetchPost()
//            }
//        }
//    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCellCollectionViewCell
        
        cell.delegate = self
        
        if singleViewPost {
            if let post = self.post {
                cell.generateCell(post: post, user: post.user!)
            }
        } else {
            var post = posts[indexPath.item]
            
            cell.feedGenerateCell(post: post, reference: post.userReference!)
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
    
    //MARK: handler
       @objc func handleRefresh() {
           //handle refresh
        posts.removeAll(keepingCapacity: false)
        
        if !singleViewPost {
            fetchPost()
        } else {
            collectionView.refreshControl?.endRefreshing()
        }
        
        collectionView.reloadData()
           
       }
    
    //MARK: fetchPost
    
    private func fetchPost() {
        
        var followingIDs = [FUser.currentID()]
        
        
        // get FofllowingIds
        
        firebaseReferences(.Following).document(FUser.currentID()).collection(kUSERFOLLOWING).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            self.collectionView.refreshControl?.endRefreshing()

            if !snapshot.isEmpty {
                for following in snapshot.documents {
                    let followId = following.documentID
                    followingIDs.append(followId)
                }

            }
            // make limit later...
            firebaseReferences(.Post).whereField(kUSERID, in: followingIDs).order(by: kCREATEDAT, descending: true).limit(to: 5).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {return}


                if !snapshot.isEmpty {
                    for doc in snapshot.documents {
                        let postDictionary = doc.data() as NSDictionary

                        let post = Post(_postId: doc.documentID, _reference: postDictionary[kUSERREFERENCE] as! DocumentReference, dictionary: postDictionary)
                        self.posts.append(post)

                    }

                    self.collectionView.reloadData()
                }
            }

        }
    }
    
   

}


extension FeedCollectionViewController : FeedCellDelegate {
    func handleUsernameTapped(for cell: FeedCellCollectionViewCell) {
        print("ああ")
    }

}
