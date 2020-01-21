import UIKit
import MessageKit
import InputBarAccessoryView


//MARK: Save & Load methods

extension MessageViewController {
    
    // Create OutGoing instance
    
    func send_Message(text : String?, picture : UIImage?, location : String?, video : NSURL?, audio : String?) {
        
        var outGoingMessage : OutGiongMessage?
        let currentUser = FUser.currentUser()!
        
        // text
        if let text = text {
            outGoingMessage = OutGiongMessage(message: text, senderId: currentUser.objectId, senderName: currentUser.firstName, status: kDELIVERED, type: kTEXT)
        }
        
        // picture
        
        if let pic = picture {
            // uploadImage
            uploadImage(image: pic, chatRoomId: chatRoomId, view: self.navigationController!.view) { (imagelink) in
                
                if imagelink != nil {
                    let text = "\(kPICTURE)"
                    
                    // instance
                    outGoingMessage = OutGiongMessage(message: text, pictureLink: imagelink!, senderId: currentUser.objectId, senderName: currentUser.firstName, status: kDELIVERED, type: kPICTURE)
                    
                    // save Database
                    outGoingMessage?.sendMessage(chatRoomId: self.chatRoomId, messageDictionary: outGoingMessage!.messageDictionary, membersIds: self.memberIds, membersToPush: self.membersToPush)
                    
                    self.finishSendMessage()
                }
            }
            // Back!
            return
            
        }
        
        // Video
        
        if let video = video {
            let videoData = NSData(contentsOfFile: video.path!)
            let thumbnailData = videoThmbnail(video: video).jpegData(compressionQuality: 0.3)
            
            // upload
            
            uploadVideo(videoUrl: videoData!, chatRoomId: chatRoomId, view: self.navigationController!.view) { (videoLink) in
                
                if videoLink != nil {
                    
                    let text = "\(kVIDEO)"
                    
                    outGoingMessage = OutGiongMessage(message: text, videoLink: videoLink!, thumbnail: thumbnailData! as NSData, senderId: currentUser.objectId, senderName: currentUser.firstName, status: kDELIVERED, type: kVIDEO)
                    
                    outGoingMessage?.sendMessage(chatRoomId: self.chatRoomId, messageDictionary: outGoingMessage!.messageDictionary, membersIds: self.memberIds, membersToPush: self.membersToPush)
                    
                    self.finishSendMessage()
                }
            }
            
            return
            
        }
        

        
        // for Text & Location type
        outGoingMessage?.sendMessage(chatRoomId: chatRoomId, messageDictionary: outGoingMessage!.messageDictionary, membersIds: memberIds, membersToPush: membersToPush)
        
    }
    
    func update_Message(messageDictionary : NSDictionary) {
        
    }
    //MARK: Load Message
    func loadMessage() {
        
        // got last 11 -(no autolistner)
        
        firebaseReferences(.Message).document(FUser.currentID()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            self.loadMessages = self.checkCorrectType(allMessages: sorted)
            
            self.insertMessage()
            
            DispatchQueue.main.async {
                self.hideIndicator()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)
                sleep(1)
                self.messagesCollectionView.isHidden = false
            }
            
            
            // listen New Chat
            self.listenForNewChat()
            

        }
    }
}

//MARK: Helpers

extension MessageViewController {
    
   
    
    func checkCorrectType(allMessages : [NSDictionary]) -> [NSDictionary] {
        
        var tempMessages = allMessages
        
        // Check type is Correct
        for message in tempMessages {
            if message[kTYPE]  != nil {
                if !self.legitType.contains(message[kTYPE] as! String) {
                    tempMessages.remove(at: tempMessages.firstIndex(of: message)!)
                }
            } else {
                tempMessages.remove(at: tempMessages.firstIndex(of: message)!)
            }
        }
        
        return tempMessages
    }
    
    func insertMessage() {
        
        maxMessageNumber = self.loadMessages.count - loadedMessageCount
        minimumMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minimumMessageNumber < 0 {
            minimumMessageNumber = 0
        }
        
        for i in minimumMessageNumber ..< maxMessageNumber {
            let messageDictionary = loadMessages[i]
            
            // append Message lists
            insertInitialMessage(messageDictionary: messageDictionary)
            
            loadedMessageCount += 1
        }
    }
    
    func insertInitialMessage(messageDictionary : NSDictionary) -> Bool {
        
        let inComingMessage = InComingMessage(_collectionView: self.messagesCollectionView)
        
        if isInComing(messageDictionary: messageDictionary) {
            
            OutGiongMessage.updateMessage(messageId: messageDictionary[kMESSAGEID] as! String, chatRoomId: chatRoomId, membersIds: memberIds)
            
        }
        
        // return Message Model
        let message = inComingMessage.createMessage(messageDIctionary: messageDictionary, chatRoomId: chatRoomId)
        
        if message != nil {
            objectMessages.append(messageDictionary)
            messageLists.append(message!)
        }
        
        return isInComing(messageDictionary: messageDictionary)
    }
    
    func isInComing(messageDictionary : NSDictionary) -> Bool{
        
        if FUser.currentID() == messageDictionary[kSENDERID] as! String {
            return false
        } else {
            return true
        }
    }
    
    func finishSendMessage() {
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
        
    }
    
    // New Chat Lioten
    
    func listenForNewChat() {
        
        var lastMessageDate = "0"
        // chage Date To String
        if loadMessages.count > 0 {
            lastMessageDate = loadMessages.last![kDATE] as! String
        }
        
        newChatListner = firebaseReferences(.Message).document(FUser.currentID()).collection(chatRoomId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snaphot, error) in
            
            guard let snapshot = snaphot else {return}
            
            if !snapshot.isEmpty {
                
                for diff in snapshot.documentChanges {
                    if diff.type == .added {
                        
                        let itm = diff.document.data() as NSDictionary
                        
                        if let type = itm[kTYPE]{
                            // check Correct Type
                            if self.legitType.contains(type as! String) {
                                
                                if self.insertInitialMessage(messageDictionary: itm) {
                                    
                                }
                                self.messagesCollectionView.reloadData()
                                
                            }
                            
                        }

                    }
                }
                
            }
            
        })
        
    }
}


