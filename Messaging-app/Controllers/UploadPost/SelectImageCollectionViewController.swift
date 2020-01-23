//
//  SelectImageCollectionViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/22.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class SelectImageCollectionViewController: UICollectionViewController , UICollectionViewDelegateFlowLayout{
    
    var images = [UIImage]()
    var assets = [PHAsset]()
    var selectedImage : UIImage?
    
    var header : SelectPhotoHeader?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SelectPhotoHeader")
        collectionView.register(SelectPhotoCell.self, forCellWithReuseIdentifier: "SelectPhotoCell")
        
        collectionView.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(showUploadPost))

       loadPhotos()
        
       
    }
    
    //MARK: collectionViewFlow Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

  
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectPhotoCell", for: indexPath) as! SelectPhotoCell
        
        cell.photoImageView.image = images[indexPath.row]
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SelectPhotoHeader", for: indexPath) as! SelectPhotoHeader
        
        self.header = header
        
        if let selectedImage = self.selectedImage {
            if let index = self.images.firstIndex(of: selectedImage) {
                
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                    
                   //MARK: set Header Image
                    
                    header.photoImageView.image = image
                }
            }
        }
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedImage = images[indexPath.row]
        self.collectionView.reloadData()
        
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    //MARK: Load Photos
    
    private func loadPhotos() {
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetOptions())
        
        DispatchQueue.global(qos: .background).async {
            
            allPhotos.enumerateObjects { (asset, count, stop) in
                
                let imagemanager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                imagemanager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                     
                        if count == allPhotos.count - 1 {
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    private func getAssetOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        options.fetchLimit = 45
        
        let sortDescriptors = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptors]
        
        return options
    }
    
    //MARK: Helper
    
    @objc func showUploadPost() {
        let uploadVC = UploadPostViewController()
        uploadVC.uploadAction = UploadPostViewController.UploadAction(index: 0)
        uploadVC.selectedImage = header?.photoImageView.image
        navigationController?.pushViewController(uploadVC, animated: true)
    }
   

}
