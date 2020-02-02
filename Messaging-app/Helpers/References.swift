//
//  References.swift
//  Messaging-app
//
//  Created by 酒井ゆうき on 2020/01/16.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum References : String {
    
    case User
    case Recent
    case Message
    case Post
    case Following
    case Follower
    case Comment
}

func firebaseReferences(_ references : References) -> CollectionReference {
    return Firestore.firestore().collection(references.rawValue)
}

func userFollowingReference(_ userId : String) -> CollectionReference {
    return firebaseReferences(.User).document(userId).collection(kUSERFOLLOWING)
}

func userFolloweredReference(_ userId : String) -> CollectionReference {
    return firebaseReferences(.User).document(userId).collection(kUSERFOLOWERS)
}
