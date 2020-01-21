//
//  Recent.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/18.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation

func startPrivateChat(user1 : FUser, user2 : FUser) -> String {
    
    let user1ID = user1.objectId
    let user2ID = user2.objectId
    
    var chatRoomID = ""
    
    let value = user1ID.compare(user2ID).rawValue
    
    if value < 0 {
        chatRoomID = user1ID + user2ID
    } else {
        chatRoomID = user2ID + user1ID
    }
    
    let members = [user1ID, user2ID]
    
    createRecentChat(members: members, chatRoomId: chatRoomID, withUserName: "", type: kPRIVATE, users: [user1,user2], avatarGroup: nil)
    
    
    // for chatVC
    return chatRoomID
}

func createRecentChat(members : [String], chatRoomId : String, withUserName : String, type : String, users : [FUser]?, avatarGroup : String?) {
    
    var tempMembers = members
    
    firebaseReferences(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {return}
        
        // check Exist
        
        if !snapshot.isEmpty {
            
            for recent in snapshot.documents {
                
                let currentRecent = recent.data() as NSDictionary
                
                if let currentUserId = currentRecent[kUSERID] {
                    if members.contains(currentUserId as! String) {
                        tempMembers.remove(at: tempMembers.firstIndex(of: currentUserId as! String)!)
                    }
                }
            }
        }
        
        for userID in tempMembers {
            // create New One
            createRecentItem(userID: userID, chatRoomId: chatRoomId, members: members, withUserName: withUserName, type: type, users: users, avatarOfGroup: nil)
        }
    }
}

func createRecentItem(userID :String, chatRoomId : String, members : [String], withUserName : String, type : String, users : [FUser]?, avatarOfGroup : String?) {
    
    let localReference = firebaseReferences(.Recent).document()
    let recentId = localReference.documentID
    
    let date = dateFormatter().string(from: Date())
    
    var recent : [String : Any]!
    
    if type == kPRIVATE {
        // for Private
        
        var withUser :FUser?
        
        if users != nil && users!.count > 0 {
            
            if userID == FUser.currentID() {
                withUser = users!.last!
            } else {
                withUser = users!.first!
            }
        }
       
        
        recent = [kRECENTID : recentId,
                  kUSERID : userID,
                  kCHATROOMID : chatRoomId,
                  kMEMBERS : members,
                  kMEMBERSTOPUSH : members,
                  kWITHUSERFULLNAME : withUser!.fullname,
                  kWITHUSERUSERID : withUser!.objectId,
                  kLASTMESSAGE : "",
                  kCOUNTER : 0,
                  kDATE : date,
                  kTYPE : type,
                  kAVATAR : withUser!.avatar ] as [String : Any]
        
    } else {
        
        // for Group
        
    }
    
    localReference.setData(recent)

    
}


// Message methods

func updateRecent(chatRoomId : String, lastMessage : String) {
    firebaseReferences(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else {return}
        
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                let currentRecent = recent.data() as NSDictionary
                
                // update LastMessage
                updateRecentItem(recent: currentRecent, lastMessage: lastMessage)
                
            }
        }
    }
}

func updateRecentItem(recent : NSDictionary, lastMessage : String) {
    
    let date = dateFormatter().string(from: Date())
    var counter = recent[kCOUNTER] as! Int
    
    if recent[kUSERID] as! String != FUser.currentID() {
        counter += 1
    }
    
    let values = [kLASTMESSAGE : lastMessage, kCOUNTER : counter, kDATE : date] as [String : Any]
    firebaseReferences(.Recent).document(recent[kRECENTID] as! String).updateData(values)
}
