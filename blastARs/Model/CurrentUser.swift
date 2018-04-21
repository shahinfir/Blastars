//
//  CurrentUser.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/22/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import FirebaseDatabase

struct CurrentUser {
    static var ref: DatabaseReference?
    static var uid: String = "" { //KeychainWrapper.standard.string(forKey: KEY_UID)! {
        willSet {
            //Remove previous observer, if already set.
                //If user logs into different account, don't want challenges to previous account
                //to trigger actions on the newly logged in account
            if ref != nil {
                print("should remove observers")
                ref!.removeAllObservers()
            }
        } didSet {
            print("new uid is \(uid)")
            ref = RealtimeService.shared.REF_USERS_PUBLIC.child(uid)
            ref!.observe(.childChanged) { (snapshot) in
                print("child changed")
                if snapshot.key == "challengeId" {
                    if let id = snapshot.value as? String {
                        //Set game id
                        CurrentGame.gameUid = id
                        print("game id is \(id)")
                        //Segue to challenged screen
                        GameObserver.shared.observeGameAsUser2(gameId: id)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil);
                        let vc = storyboard.instantiateViewController(withIdentifier: "ChallengedVC") as! ChallengedVC
                        let rootViewController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
                        rootViewController.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
}
