//
//  Comments.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/02/02.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation

class Comment{
    
    var userId : String!
    var commentText : String!
    var creationDate : Date!
    var user : FUser?
    
    init(dictionary : [String : Any]) {
   
        if let userId = dictionary[kUSERID] as? String {
            self.userId = userId
        }
        
        if let commentText = dictionary[kCOMMENT] as? String {
            self.commentText = commentText
        }
        
        if let creationDate = dictionary[kCREATEDAT] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }

        
    }
    
    
}
