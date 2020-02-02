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
    var likes : Int!
    
    var createtionDate : Date!
//    var updateDate : String?

    var postDIctionary : NSDictionary?
    
    var userReference : DocumentReference?

    var user : FUser?
    var didLike = false

   // for profile
    init(_user : FUser, dictionary : NSDictionary) {
        
        user = _user
        
        if let _postId = dictionary[kPOSTID] as? String {
            postId = _postId
        }
        
        if let _caption = dictionary[kCAPTION] as? String {
            caption = _caption
        }
        
        if let likes = dictionary[kLIKE] as? Int {
            self.likes = likes
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
        
        if let likes = dictionary[kLIKE] as? Int {
            self.likes = likes
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
    
    //MARK: Like Area
    
    func checkUserLiked(completion : @escaping(Bool) -> ()) {
        let doc = firebaseReferences(.Post).document(self.postId).collection(kLIKE).document(FUser.currentID())
        
        doc.getDocument { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            if snapshot.exists {
                completion(true)
            } else {
                completion(false)
            }
            
        }
    }
    
    func adjustLike(addLike : Bool, completion : @escaping(Int) -> ()) {
        
        guard let postId = self.postId else {return}
        
        let date = dateFormatter().string(from: Date())
        
        if addLike {
            firebaseReferences(.Post).document(postId).collection(kLIKE).document(FUser.currentID()).setData([kCREATEDAT : date])
            firebaseReferences(.Post).document(postId).updateData([kLIKE : FieldValue.increment(Int64(1))])
            self.didLike = true
            self.likes += 1
            completion(self.likes)
            
        } else {
            firebaseReferences(.Post).document(postId).collection(kLIKE).document(FUser.currentID()).delete()
            firebaseReferences(.Post).document(postId).updateData([kLIKE : FieldValue.increment(Int64(-1))])
            self.didLike = false
            self.likes -= 1
            completion(self.likes)
        }
        
    }
    
}




