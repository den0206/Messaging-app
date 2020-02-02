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
        
        return containerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // configure collectionviw base
        configureCollectionView()
        
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
    
    

}


extension CommentViewController : CommentInputAccesaryViewDelegate {
    
    //MARK: didSubmit
       
       func didSubmit(comment: String) {
            print("post")
        }
        
        
}
