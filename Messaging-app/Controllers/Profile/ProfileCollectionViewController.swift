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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)

        collectionView?.backgroundColor = .white
        
        //MARK: fetchPost
        
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
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
   
    
        return cell
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        
        //        self.header = header
        
        header.user = user
        navigationItem.title = user?.fullname
        
        if user != nil {
            header.generateCell(user: user!, indexPath: indexPath)
            
        }
        
        return header
    }
    
    //MARK: FetchPosts
    
    private func fetchPosts() {
                   
        firebaseReferences(.Post).document(user!.objectId).collection(kPOST).getDocuments { (snapshot, error) in
           
            guard let snapshot = snapshot else {return}
            
            if !snapshot.isEmpty {
                print(snapshot)
            }
        }
            
        
    }
    
}
