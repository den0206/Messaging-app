//
//  UploadPostViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/22.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit

class UploadPostViewController: UIViewController, UITextViewDelegate {
    
    //MARK:Upload Actions
    
    enum UploadAction : Int {
        case UploadPost
        case SaveChange
        
        init(index : Int) {
            
            switch index {
            case 0 : self = .UploadPost
            case 1: self = .SaveChange
            default: self = .UploadPost
            }
        }
    }
    
    var uploadAction : UploadAction!
    var selectedImage : UIImage?
    
    //MARK: Parts
    
    let photoImageView : CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let captionLabel : UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.systemGroupedBackground
        tv.font = UIFont.systemFont(ofSize: 12)
        return tv
    }()
    let actionButton : UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor =  UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.setTitle("Share!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(savePost), for: .touchUpInside)
        
        
        return button
    }()
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewComponents()
        loadImage()
        
        captionLabel.delegate = self

       
    }
    
    //MARK: ConfigureViewComponents
    
    private func configureViewComponents() {
        view.backgroundColor = .white
        
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        view.addSubview(captionLabel)
        captionLabel.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
        
        view.addSubview(actionButton)
        actionButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40)
        
    }
    
    //MARK:TextField Delegate (textView doesn't have ADD TARGET)
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard captionLabel.hasText else {
            actionButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            actionButton.isEnabled = false
            return
        }
        actionButton.backgroundColor = .blue
        actionButton.isEnabled = true
    }
    
    //MARK: Save Post In firestore & Storoge
    
    @objc func savePost() {
        guard
            let postImage = photoImageView.image,
            let captionLabel = captionLabel.text
            else { return }
    
        let postId = UUID().uuidString
//        let date = dateFormatter().string(from: Date())
        
        // creation date
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // upload Stroge
        
        uploadPostImage(image: postImage, PostId: postId, view: self.navigationController!.view) { (imageLink) in
       
            if imageLink != nil {
                let withValue = [kCAPTION : captionLabel,
                                     kPICTURE : imageLink!,
                                     kLIKE : 0,
                                     kCREATEDAT : creationDate,
                                     kUSERID : FUser.currentID()] as [String : Any]
                
                // set Firestore
                
//                firebaseReferences(.Post).document(FUser.currentID()).collection(postId).document().setData(withValue)
                firebaseReferences(.Post).document(FUser.currentID()).collection(kPOST).document(postId).setData(withValue)
                
                self.navigationController?.popToRootViewController(animated: true)
                
            }
            
           
            
        }
        
        
    }
    
    //MARK: LoadImage
    
    private func loadImage() {
        guard let selectedImage = selectedImage else {
            return
        }
        
        photoImageView.image = selectedImage
    }
    


}
