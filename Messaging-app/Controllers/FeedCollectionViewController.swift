//
//  FeedCollectionViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/22.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class FeedCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(FeedCellCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.title = "Feed"
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(showUploadPostVC))
        navigationItem.rightBarButtonItem = rightButton

      
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FeedCellCollectionViewCell
    
        return cell
    }
    
    @objc func showUploadPostVC() {
        let selectVC = SelectImageCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        navigationController?.pushViewController(selectVC, animated: true)
    }

}
