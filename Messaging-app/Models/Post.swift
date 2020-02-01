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
    init(_user : FUser, dictionary : NSDictionary) {
        
        user = _user
        
        if let _postId = dictionary[kPOSTID] as? String {
            postId = _postId
        }
        
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
    
    init(_reference : DocumentReference, dictionary : NSDictionary) {
        
        userReference = _reference
        
        if let _postId = dictionary[kPOSTID] as? String {
            postId = _postId
        }
        
        if let _caption = dictionary[kCAPTION] as? String {
            caption = _caption
        }
        
        if let _userID = dictionary[kUSERID] as? String {
            userId = _userID
            
             self.syncUser()
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
    
    func syncUser() {
        firebaseReferences(.User).document(userId).getDocument { (snapshot, error) in
            if let user = snapshot.flatMap({ FUser(_dictionary: $0.data()! as NSDictionary) }) {
                //Set the user on this Post
                self.user = user
            } else {
                print("Document does not exist")
            }
            
            
        }
        
    }
}




