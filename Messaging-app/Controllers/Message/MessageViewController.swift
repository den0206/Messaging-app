//
//  MessageViewController.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/19.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import NVActivityIndicatorView
import AVFoundation
import AVKit

class MessageViewController: MessagesViewController {
    
    //MARK: Vars
    
    var messageLists : [Message] = []
    var loadMessages : [NSDictionary] = []
    var objectMessages : [NSDictionary] = []
    
    var chatRoomId : String!
    var memberIds : [String]!
    var membersToPush : [String]!
    
    //MARK: Listner
    // NewChat
    var newChatListner : ListenerRegistration?
    
//    //Read
//    var updatelistner : ListenerRegistration?
    
    let legitType = [kAUDIO, kVIDEO, kLOCATION, kTEXT, kPICTURE]
    
    var maxMessageNumber = 0
    var minimumMessageNumber = 0
    var loadedMessageCount = 0
    
    var avatarItems : NSMutableDictionary?
    var avatarImageDictionary : NSMutableDictionary?

    var isGrouped : Bool = false
    
//    deinit {
//        updatelistner?.remove()
//    }
    
    //MARK: Activity Indicator
    
    var activityIndicator : NVActivityIndicatorView?
    let randomRed: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
    let randomGreen: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
    let randomBlue: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // delegate AREA
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        
        // random BackGround
        setRandomBackgroundColor()
        
        hideCurrentUserAvatar()
        
        configureInputView()
        
        configureAccesary()
        
        loadMessage()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: view.frame.width / 2 - 30, y: view.frame.height / 2 - 30, width: 60.0, height: 60.0), type: .ballPulse, color: UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0), padding: nil)
        
        startIndicator()
    }
    
    private func configureInputView() {
        messageInputBar.sendButton.tintColor = .darkGray
        messageInputBar.backgroundView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        messageInputBar.inputTextView.backgroundColor = .white
    }
    
    private func setRandomBackgroundColor() {
        
        
        self.messagesCollectionView.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 0.6)
    }
    
    func startIndicator() {
        
        if activityIndicator != nil {
            self.messagesCollectionView.addSubview(activityIndicator!)
            activityIndicator?.startAnimating()
        }
    }
    
    func hideIndicator() {
        
        if activityIndicator != nil {
            activityIndicator?.removeFromSuperview()
            activityIndicator?.stopAnimating()
        }
    }
    
    
}


//MARK: Message Datasource

extension MessageViewController : MessagesDataSource {
    
    func currentSender() -> SenderType {
        
        return Sender(senderId: FUser.currentID(), displayName: FUser.currentUser()!.fullname)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {

        return messageLists[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageLists.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if indexPath.section % 3 == 0 {
            
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    
    
    
    
    
    // メッセージの上に文字を表示（日付）
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    // メッセージの下に文字を表示（既読）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let messageDictionary = objectMessages[indexPath.section]
        let status : NSAttributedString
        //        let atributeStringColor = [NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        
        if isFromCurrentSender(message: message) {
            switch messageDictionary[kSTATUS] as! String{
            case kDELIVERED:
                status = NSAttributedString(string: kDELIVERED, attributes:  [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
            case kREAD :
                status = NSAttributedString(string: kREAD, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
            default:
                status = NSAttributedString(string: "✔︎", attributes:  [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
            }
            
            return status
        }
        
        return nil
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let message = messageLists[indexPath.section]
        var avatar : Avatar
        
        if avatarItems != nil {
            
            if let avatarData = avatarItems!.object(forKey: message.sender.senderId) {
                
                avatar = avatarData as! Avatar
                avatarView.set(avatar: avatar)
            }
            
        } else {
            avatar = Avatar(image: UIImage(named: "avatarPlaceholder") , initials: "?")
            avatarView.set(avatar: avatar)
        }
    }
    
    func hideCurrentUserAvatar() {
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
    }
    
    
}

//MARK: Message Layout Delagate

extension MessageViewController : MessagesLayoutDelegate {
    
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 30
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 35
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 30
    }
}

//MARK: Message Dissplay Delegate

extension MessageViewController : MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .black
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        isFromCurrentSender(message: message) ?
        UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
        UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
               
               return .bubbleTail(corner, .curved)
    }
    
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
         return isFromCurrentSender(message: message) ? .white : UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
    }
    
//    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
//
//    }
}

  //MARK: MessageCellDelegate(Tap Acton)

extension MessageViewController : MessageCellDelegate {
    

    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let message = messageLists[indexPath.section]
            
            switch message.kind {
            case .photo:
                print("photo")
            case .video(var videoItem):
                
                if let videoUrl = videoItem.fileUrl {
                    let player = AVPlayer(url: videoUrl as URL)
                    let avplayer = AVPlayerViewController()
                    
                    let session = AVAudioSession.sharedInstance()
                    
                    try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                    
                    avplayer.player = player
                    
                    present(avplayer, animated: true) {
                        avplayer.player!.play()
                    }
                }
            case .location :
                print("Location")
            case .audio :
                print("Audio")
            default:
                break
            }
        }
    }

    
}

//MARK: input Accesary View

extension MessageViewController : InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                self.send_Message(text: text, picture: nil, location: nil, video: nil, audio: nil)
            }
        }
        // send animation
        finishSendMessage()
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text == "" {
            // show mic
            setAudioButton()
            
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
        }
    }
    
}

//MARK: Accesary & ImagePicker

extension MessageViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func configureAccesary(){
        
        // configure Left button
        
        let optionItems = InputBarButtonItem(type: .system)
        optionItems.tintColor = .darkGray
        optionItems.image = UIImage(named: "clip")
        
        optionItems.setSize(CGSize(width: 60, height: 30), animated: true)
        optionItems.addTarget(self, action: #selector(showOptions), for: .touchUpInside)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([optionItems], forStack: .left, animated: true)
        
        //configure Right Button
        setAudioButton()
          
    }
    
    @objc func showOptions() {
        
        let camera = Camera(delegate_: self)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // take picture or Video
        let takePhotoVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("take device")
        }
        
        let showPhoto = UIAlertAction(title: "library", style: .default, handler: { (action) in
            camera.PresentPhotoLibrary(target: self, canEdit: false)
        })
        
        let shareVideo = UIAlertAction(title: "Video", style: .default) { (action) in
            camera.PresentVideoLibrary(target: self, canEdit: false)
        }
        
        let shareLocation = UIAlertAction(title: "Location", style: .default) { (action) in
            print("Location")
        }
        
        //MARK: Cancel
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        })
        
        
        takePhotoVideo.setValue(UIImage(named: "camera"), forKey: "image")
        showPhoto.setValue(UIImage(named: "picture"), forKey: "image")
        shareVideo.setValue(UIImage(named: "video"), forKey: "image")
        shareLocation.setValue(UIImage(named: "location"), forKey: "image")
        
        let actionsArray : [UIAlertAction] = [takePhotoVideo, showPhoto, shareVideo,shareLocation,cancel]
        
        for action in actionsArray {
            optionMenu.addAction(action)
        }
        
        present(optionMenu, animated: true, completion: nil)

    }
    
    func setAudioButton(){
        let micItem = InputBarButtonItem(type: .system)
        micItem.tintColor = .darkGray
        micItem.image = UIImage(named: "mic")
        micItem.setSize(CGSize(width: 60, height: 30), animated: true)
        
        // add Action
        micItem.addTarget(self, action: #selector(pushAudio), for: .touchUpInside)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setRightStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([micItem], forStack: .right, animated: true)
        
    }
    
    @objc func pushAudio() {
        print("aa")
    }
    
    //MARK: Imagepicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        self.dismiss(animated: true) {
            let picure = info[.originalImage] as? UIImage
            let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
            
            self.send_Message(text: nil, picture: picure, location: nil, video: video, audio: nil)
        }
    }
    
}

