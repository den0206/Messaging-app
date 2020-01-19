//
//  MessageViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/19.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import MessageKit

class MessageViewController: MessagesViewController {
    
    //MARK: Vars
    
    var chatRoomId : String!
    var memberIds : [String]!
    var membersToPush : [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.chatRoomId)
//        print(self.memberIds)
//        print(self.membersToPush)
    }
    

}
