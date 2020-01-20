//
//  OutGoingMessage.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/19.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation

class OutGiongMessage {
    
    let messageDictionary : NSMutableDictionary
    
    // Text
    
    init(message : String, senderId : String, senderName : String, status : String, type : String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, senderId,senderName,status,type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    func sendMessage(chatRoomId : String, messageDictionary : NSMutableDictionary, membersIds : [String], membersToPush : [String]) {
        
        let messageId = UUID().uuidString
        let date = dateFormatter().string(from: Date())
        
        messageDictionary[kMESSAGEID] = messageId
        messageDictionary[kDATE] = date
        
        for member in membersIds {
            firebaseReferences(.Message).document(member).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String : Any])
        }
        
        // update lastMessage
    }


}
