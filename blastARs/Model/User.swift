//
//  User.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/19/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import Foundation

class User {
    
    private var _uid: String!
    private var _username: String!
    
    var uid: String {
        return _uid
    }
    
    var username: String {
        return _username
    }
    
    
    init(userData: Dictionary<String, Any>) {
        if let uid = userData["uid"] as? String {
            self._uid = uid
        }
        if let username = userData["username"] as? String {
            self._username = username
        }
    }
}
