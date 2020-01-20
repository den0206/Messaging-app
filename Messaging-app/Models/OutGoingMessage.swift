//
//  OutGoingMessage.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/19.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import Foundation

class OutGiongMessage {
    
    let messageDictionary : NSMutableDictionary
    
    //MARK: each Type of init
    
    // Text
    
    init(message : String, senderId : String, senderName : String, status : String, type : String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, senderId,senderName,status,type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    // picture
    
    init(message : String, pictureLink : String, senderId : String, senderName : String, status : String, type : String) {
        
        messageDictionary = NSMutableDictionary(objects: [message,pictureLink,senderId,senderName,status,type], forKeys: [kMESSAGE as NSCopying,kPICTURE as NSCopying,kSENDERID as NSCopying, kSENDERNAME as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
        
    }
    
    // save each Message FioreStore
    
    
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
    
    // update Read Message
    
    class func updateMessage(messageId : String, chatRoomId : String, membersIds : [String]) {
        
        let readDate = dateFormatter().string(from: Date())
        let value = [kSTATUS : kREAD, kREADDATE : readDate]
        
        for userId in membersIds {
            firebaseReferences(.Message).document(userId).collection(chatRoomId).document(messageId).updateData(value)
        }
        
    }


}
