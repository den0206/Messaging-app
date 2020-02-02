//
//  CommentViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/02/02.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CommentCell"


class CommentViewController: UICollectionViewController ,UICollectionViewDelegateFlowLayout {
 
    var post : Post?
    var comments = [Comment]()
    
    lazy var containerView: CommentInputAccesaryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let containerView = CommentInputAccesaryView(frame: frame)
        
        containerView.delegate = self
//        containerView.commentTextView.delegate = self
        
        return containerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // configure collectionviw base
        configureCollectionView()
        
        fetchComment()
        
    }
    
    //MARK: dismiss tabBar
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        
    }
    
   override var inputAccessoryView: UIView? {
       get {
           return containerView
       }
   }
   
   override var canBecomeFirstResponder: Bool {
       return true
   }

    // MARK: UICollectionViewDataSource

  
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return comments.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        
        let comment = comments[indexPath.item]
        
        fetchUserIDinFiresore(comment.userId) { (user) in
            cell.generateCell(user: user, comment: comment)
        }
        
    
        return cell
    }
    
    //MARK: Helper
    
    private func configureCollectionView() {
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        title = "Comment"
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    //MARK: Fetch Comment
    private func fetchComment() {
        guard let postId = post?.postId else {return}
        
        firebaseReferences(.Post).document(postId).collection(kCOMMENT).order(by: kCREATEDAT, descending: true).getDocuments { (snapshot, error) in
            
            guard let querySnapshot = snapshot else {return}
            
            if !querySnapshot.isEmpty {
                for doc in querySnapshot.documents {
                    let commentDic = doc.data()
                    let comment = Comment(dictionary: commentDic)
                    self.comments.append(comment)
                }
                print(self.comments.count)
                self.collectionView.reloadData()
            }
        }
    }
    
    

}


extension CommentViewController : CommentInputAccesaryViewDelegate{
    
    //MARK: Add Post
    
    func didSubmit(comment: String) {
        
        let commentId = UUID().uuidString
        guard let postId = post?.postId else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = [kCREATEDAT : creationDate,
                     kCOMMENT : comment,
                     kPOSTID : postId,
                     kUSERID : FUser.currentID()] as [String : Any]
        
        firebaseReferences(.Post).document(postId).collection(kCOMMENT).document(commentId).setData(values) { (error) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            self.containerView.clearConnentTextView()
            
            
        }
        
        
    }
    
    
}
