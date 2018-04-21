//
//  CurrentGame.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/22/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import Firebase

struct CurrentGame {
    static var opponentRef: DatabaseReference!
    static var selfRef: DatabaseReference!
    static var gameUid: String = ""
    static var selfUid: String = "" {
        didSet {
            print("self uid is \(selfUid)")
            selfRef = RealtimeService.shared.REF_CHALLENGES.child(gameUid).child(selfUid)
        }
    }
    static var opponentUid: String = "" {
        didSet {
            print("opponent uid is \(opponentUid)")
            opponentRef = RealtimeService.shared.REF_CHALLENGES.child(gameUid).child(opponentUid)
        }
    }
}
