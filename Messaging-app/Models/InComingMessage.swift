//
//  InComingMessage.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/20.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation
import MessageKit

class InComingMessage {
    
    var collectionView : MessagesCollectionView
    
    init(_collectionView : MessagesCollectionView) {
        collectionView = _collectionView
    }
    
    //MARK: Return MessageType
    
    func createMessage(messageDIctionary : NSDictionary, chatRoomId : String) -> Message? {
        
        var message : Message?
        let type = messageDIctionary[kTYPE] as! String
        
        switch type {
        case kTEXT:
            message = textMessage(messageDictionary: messageDIctionary, chatRoomID: chatRoomId)
        case kPICTURE :
            print("picture")
        case kVIDEO :
            print("kVideo")
        case kLOCATION :
            print("Lication")
        default:
            print("タイプがわかりません")
            
        }
        
        if message != nil {
            return message
        }
        
        return nil

    
    }
    
    //MARK: Text
    
    func textMessage(messageDictionary : NSDictionary, chatRoomID : String) -> Message {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userid = messageDictionary[kSENDERID] as? String
        let messageId = messageDictionary[kMESSAGEID] as? String
        
        var date : Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count !=  14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
        } else {
            date = Date()
        }
        
        let text = messageDictionary[kMESSAGE] as! String
        
        return Message(text: text, sender: Sender(senderId: userid!, displayName: name!), messageId: messageId!, date: date)
        
    }
}
