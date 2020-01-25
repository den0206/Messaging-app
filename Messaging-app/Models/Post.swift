//
//  File.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/23.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation

class Post{

    var caption : String!
    var userId : String!
    var imageLink : String!
    var postId : String!
    
    var createtionDate : Date!
//    var updateDate : String?

    var postDIctionary : NSDictionary?

    var user : FUser?

   
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
    

}
