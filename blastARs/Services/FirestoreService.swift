//
//  FirestoreService.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/20/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import Foundation
import FirebaseFirestore
import SwiftKeychainWrapper


let FS_BASE = Firestore.firestore()

class FirestoreService {
    
    private init() {}
    static let shared = FirestoreService()
    
    private var _REF_USERS = FS_BASE.collection("users")
    
    
    //Firestore
    var REF_USERS: CollectionReference {
        return _REF_USERS
    }
    
    var REF_CURRENT_USER: DocumentReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.document(uid!)
        return user
    }
    
    
    func createFirestoreUser(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.document(uid).setData(userData, options: SetOptions.merge())
    }
    
    func addUserDetail(userData: Dictionary<String, Any>, completion: @escaping() -> Void) {
        REF_CURRENT_USER.updateData(userData) { (error) in
            if error == nil {
               completion()
            }
        }
    }
    
//    func getUid(fromUsername username: String, completion: @escaping(true) -> Void) {
//        
//    }
    

}
