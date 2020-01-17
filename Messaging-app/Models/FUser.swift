//
//  FUser.swift
//  InsCopy
//
//  Created by 酒井ゆうき on 2020/01/12.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation
import FirebaseAuth

class FUser {
    
    
    let objectId : String
    var pushId: String?
    
    let createdAt: Date
    var updatedAt: Date
    
    var email: String
    var firstName: String
    var lastName : String
    var fullname : String
    var avatar: String
    var isOnline: Bool
    
    var contacts: [String]
    var blockedUsers: [String]
    let loginMethod: String
    var isFollowed = false
    
    init(_objectId: String, _pushId: String?, _createdAt: Date, _updatedAt: Date, _email: String, _firstName: String,_lastName: String ,_avatar: String , _loginMethod: String) {
        
        objectId = _objectId
        pushId = _pushId
        createdAt = _createdAt
        updatedAt = _updatedAt
        email = _email
        firstName = _firstName
        lastName = _lastName
        fullname = firstName + " " + lastName
        avatar = _avatar
        isOnline = true
        
        loginMethod = _loginMethod
        blockedUsers = []
        contacts = []
    }
    
    init(_dictionary : NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        pushId = _dictionary[kPUSHID] as? String
        
        if let created = _dictionary[kCREATEDAT] {
            if (created as! String).count != 14 {
                createdAt = Date()
            } else {
                createdAt = dateFormatter().date(from: created as! String)!
            }
        } else {
            createdAt = Date()
        }
        if let updateded = _dictionary[kUPDATEDAT] {
            if (updateded as! String).count != 14 {
                updatedAt = Date()
            } else {
                updatedAt = dateFormatter().date(from: updateded as! String)!
            }
        } else {
            updatedAt = Date()
        }
        
        if let userN = _dictionary[kFISRSTNAME]{
            firstName = userN as! String
        } else {
            firstName = ""
        }
        
        if let userN = _dictionary[kLATNAME]{
            lastName = userN as! String
        } else {
            lastName = ""
        }
        
        fullname = firstName + " " + lastName
        
        
        if let mail = _dictionary[kEMAIL] {
            email = mail as! String
        } else {
            email = ""
        }
       
      
        if let avat = _dictionary[kAVATAR] {
            avatar = avat as! String
        } else {
            avatar = ""
        }
        if let onl = _dictionary[kISONLINE] {
            isOnline = onl as! Bool
        } else {
            isOnline = false
        }
     
       
        if let cont = _dictionary[kCONTACT] {
            contacts = cont as! [String]
        } else {
            contacts = []
        }
        if let block = _dictionary[kBLOCKEDUSERID] {
            blockedUsers = block as! [String]
        } else {
            blockedUsers = []
        }
        
        if let lgm = _dictionary[kLOGINMETHOD] {
            loginMethod = lgm as! String
        } else {
            loginMethod = ""
        }
     
    }
    
    //MARK: Current-User
    
    class func currentID() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> FUser? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                return FUser(_dictionary: dictionary as! NSDictionary)
            }
        }
        
        return nil
    }
    
    //MARK: Refister & Login
    
    class func registerUser(email : String, password: String, firstName : String,lastName : String,  avatar : String = "",  completion : @escaping(_ error : Error?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authUser, error) in
            
            if error != nil {
                completion(error)
                return
            }
            
           
            
            let fUser = FUser(_objectId: authUser!.user.uid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _email: email, _firstName: firstName, _lastName: lastName, _avatar: avatar, _loginMethod: kEMAIL)
            
            saveUserLocal(fUser)
            saveUserToFiresore(fUser)
            completion(error)
            
        }
    }
    
    class func loginUser(email : String, password : String, completion : @escaping(_ error : Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authData, error) in
            
            if error != nil {
                completion(error)
                return
            } else {
                
                // get User From Firestore
                fetchUserFromFirestore(authData!.user.uid)
                completion(error)
            }
        }
        
    }
    
    class func logOutCurrentUser(completion : @escaping(_ success : Bool) -> Void) {
        
        userDefaults.removeObject(forKey: kCURRENTUSER)
        userDefaults.synchronize()
        
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch let error as NSError {
            completion(false)
            print(error.localizedDescription)
        }
        
        
    }
    
}  // send of User Class

func updateCurrentUserInFirestore(withValues : [String : Any], completion : @escaping(_ error : Error?) -> Void) {
    
    if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
        
        var tempwithValues = withValues
        let currentId = FUser.currentID()
        
        let updateAt = dateFormatter().string(from: Date())
        
        tempwithValues[kUPDATEDAT] = updateAt
        
        let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
        print(userObject)
        userObject.setValuesForKeys(tempwithValues)
        
        firebaseReferences(.User).document(currentId).updateData(withValues) { (error) in
            
            if error != nil {
                completion(error)
                return
            }
            
            UserDefaults.standard.setValue(userObject, forKey: kCURRENTUSER)
            UserDefaults.standard.synchronize()
            completion(error)
        }
        
    }
    
}

func fetchUserFromFirestore(_ userId : String) {
    
    firebaseReferences(.User).document(userId).getDocument { (snapshot, error) in
        
        guard let snapshot = snapshot else {return}
        
        if snapshot.exists {
            
            print("成功")
            
            UserDefaults.standard.setValue(snapshot.data()! as NSDictionary, forKeyPath: kCURRENTUSER)
            UserDefaults.standard.synchronize()
        }
        
        
    }
}

func saveUserLocal(_ user : FUser) {
    UserDefaults.standard.set(userDictionaryFrom(user: user), forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
}

func userDictionaryFrom(user: FUser) -> NSDictionary {
    
    let createdAt = dateFormatter().string(from: user.createdAt)
    let updatedAt = dateFormatter().string(from: user.updatedAt)
    
    return NSDictionary(objects: [user.objectId, createdAt, updatedAt, user.email, user.loginMethod, user.pushId!, user.firstName, user.lastName,user.fullname, user.avatar, user.contacts, user.blockedUsers, user.isOnline ], forKeys: [kOBJECTID as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kEMAIL as NSCopying, kLOGINMETHOD as NSCopying, kPUSHID as NSCopying,  kFISRSTNAME as NSCopying, kLATNAME as NSCopying, kFULLNAME as NSCopying, kAVATAR as NSCopying, kCONTACT as NSCopying, kBLOCKEDUSERID as NSCopying, kISONLINE as NSCopying])
    
}

func saveUserToFiresore(_ user : FUser) {
    firebaseReferences(.User).document(user.objectId).setData(userDictionaryFrom(user: user) as! [String : Any]) { (error) in
        
        print(error?.localizedDescription)
    }
}

