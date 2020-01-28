//
//  File.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/23.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Post{

    var caption : String!
    var userId : String!
    var imageLink : String!
    var postId : String!
    
    var createtionDate : Date!
//    var updateDate : String?

    var postDIctionary : NSDictionary?
    
    var userReference : DocumentReference?

    var user : FUser?

   // for profile
    init(_postID : String, _user : FUser, dictionary : NSDictionary) {
        
        postId = _postID
        user = _user
        
        if let _caption = dictionary[kCAPTION] as? String {
            caption = _caption
        }
        
        if let _userID = dictionary[kUSERID] as? String {
            userId = _userID
        }
        if let _imageLink = dictionary[kPICTURE] as? String {
            imageLink = _imageLink
        }
        
        if let _creationDate = dictionary[kCREATEDAT] as? Double{
            createtionDate = Date(timeIntervalSince1970: _creationDate)
        }
        
    }
    
    // for feed
    
    init(_postId : String, _reference : DocumentReference, dictionary : NSDictionary) {
        
//        _reference.getDocument { (snapshot, error) in
//            guard let snapshot = snapshot else {return}
//
//            if snapshot.exists {
//                let userDictionary = snapshot.data()! as NSDictionary
//
//                self.user = FUser(_dictionary: userDictionary)
//            }
//        }
        userReference = _reference
        
        postId = _postId
        
        if let _caption = dictionary[kCAPTION] as? String {
            caption = _caption
        }
        
        if let _userID = dictionary[kUSERID] as? String {
            userId = _userID
        }
        if let _imageLink = dictionary[kPICTURE] as? String {
            imageLink = _imageLink
        }
        
        if let _creationDate = dictionary[kCREATEDAT] as? Double{
            createtionDate = Date(timeIntervalSince1970: _creationDate)
        }
    }
    
    
    func deletePost(post : Post) {
        
        guard let imageUrl = post.imageLink else {return}
        guard let postId = post.postId else {return}
        
        storage.reference(forURL: imageUrl).delete { (error) in
            
            if error != nil {
                print("削除できませんでした。")
            }
            
            firebaseReferences(.Post).document(postId).delete { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                }

            }
        }
    }
    

}
