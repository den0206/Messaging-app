//
//  Constracts.swift
//  InsCopy
//
//  Created by 酒井ゆうき on 2020/01/12.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation

let userDefaults = UserDefaults.standard

//NOTIFICATIONS
public let USER_DID_LOGIN_NOTIFICATION = "UserDidLoginNotification"
public let APP_STARTED_NOTIFICATION = "AppStartedNotification"
public let kFILEREFERENCE = "gs://messaging-app-ef3aa.appspot.com"

public let kBACKGROUBNDIMAGE = "backgroundImage"
public let kSHOWAVATAR = "showAvatar"
public let kPASSWORDPROTECT = "passwordProtect"
public let kFIRSTRUN = "firstRun"
public let kNUMBEROFMESSAGES = 10
public let kMAXDURATION = 120.0
public let kAUDIOMAXDURATION = 120.0
public let kSUCCESS = 2


//FUser
public let kOBJECTID = "objectId"
public let kCREATEDAT = "createdAt"
public let kUPDATEDAT = "updatedAt"
public let kEMAIL = "email"
public let kLOGINMETHOD = "loginMethod"
public let kPUSHID = "pushId"
public let kCONTACT = "contact"
public let kFISRSTNAME = "firstName"
public let kLATNAME = "lastName"
public let kFULLNAME = "fullName"
public let kAVATAR = "avatar"
public let kCURRENTUSER = "currentUser"
public let kISONLINE = "isOnline"
public let kVERIFICATIONCODE = "firebase_verification"
public let kBLOCKEDUSERID = "blockedUserId"

//recent
public let kCHATROOMID = "chatRoomID"
public let kUSERID = "userId"
public let kDATE = "date"
public let kPRIVATE = "private"
public let kGROUP = "group"
public let kGROUPID = "groupId"
public let kRECENTID = "recentId"
public let kMEMBERS = "members"
public let kMESSAGE = "message"
public let kMEMBERSTOPUSH = "membersToPush"
public let kDISCRIPTION = "discription"
public let kLASTMESSAGE = "lastMessage"
public let kCOUNTER = "counter"
public let kTYPE = "type"
public let kWITHUSERUSERNAME = "withUserUserName"
public let kWITHUSERFULLNAME = "withUserFullName"
public let kWITHUSERUSERID = "withUserUserID"
public let kOWNERID = "ownerID"
public let kSTATUS = "status"
public let kMESSAGEID = "messageId"
public let kNAME = "name"
public let kSENDERID = "senderId"
public let kSENDERNAME = "senderName"
public let kTHUMBNAIL = "thumbnail"
public let kISDELETED = "isDeleted"

//message types
public let kPICTURE = "picture"
public let kTEXT = "text"
public let kVIDEO = "video"
public let kAUDIO = "audio"
public let kLOCATION = "location"

//coordinates
public let kLATITUDE = "latitude"
public let kLONGITUDE = "longitude"


//message status
public let kDELIVERED = "delivered"
public let kREAD = "read"
public let kREADDATE = "readDate"
public let kDELETED = "deleted"

// Post
public let kCAPTION = "caption"
public let kPOSTID = "postId"
public let kLIKE = "like"
public let kPOST = "post"
public let kUSERREFERENCE  = "UserReference"

// social
public let kUSERFOLLOWING = "userFollowing"
public let kUSERFOLOWERS = "userFollowers"

// comment
public let kCOMMENT = "comment"


