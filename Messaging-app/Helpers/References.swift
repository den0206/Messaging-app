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
}

func firebaseReferences(_ references : References) -> CollectionReference {
    return Firestore.firestore().collection(references.rawValue)
}
