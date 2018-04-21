//
//  GameObserver.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/23/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import Foundation
import Firebase

class GameObserver {
    
    private init() {}
    static let shared = GameObserver()
    
    func observeGameAsHost(gameId: String) {
        let ref = RealtimeService.shared.REF_CHALLENGES.child(gameId)
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "CalibrateVC") as! CalibrateVC
        
        ref.child("didAccept").observe(.value) { (snapshot) in
            if snapshot.value as? Bool == true {
                rootViewController.pushViewController(vc, animated: true)
            }
        }
        
        ref.child("didDecline").observe(.value) { (snapshot) in
            if snapshot.value as? Bool == true {
                rootViewController.popViewController(animated: true)
                //Remove these observers
                ref.removeAllObservers()
            }
        }
        
        ref.child("didPlayerLeave").observe(.value) { (snapshot) in
            if snapshot.value as? Bool == true {
                //TODO: does this go back to main menu? It should
                rootViewController.popViewController(animated: true)
                //Remove these observers
                ref.removeAllObservers()
            }
        }
        //1. Initiate a rematch; 2. Send players back to the appropriate screen; 3. reset game stats
//        ref.child("shouldRematch").observe(.value) { (snapshot) in
//            if snapshot.value as? Bool == true {
//                //Reset game stats
//                RealtimeService.shared.resetGame(completion: { (bool) in
//                    guard bool == true else {return}
//                    rootViewController.popViewController(animated: true)
//                })
//            }
//        }
        
    }
    
    func observeGameAsUser2(gameId: String) {
        let ref = RealtimeService.shared.REF_CHALLENGES.child(gameId)
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "BattleVC") as! BattleVC
       
        ref.child("user2Uid").observe(.value) { (snapshot) in
            if let selfUid = snapshot.value as? String {
                CurrentGame.selfUid = selfUid
            }
        }
        
        ref.child("hostUid").observe(.value) { (snapshot) in
            if let opponentUid = snapshot.value as? String{
                CurrentGame.opponentUid = opponentUid
            }
        }
        
        ref.child("didAccept").observe(.value) { (snapshot) in
            if snapshot.value as? Bool == true {
                
            }
        }
        
        ref.child("didDecline").observe(.value) { (snapshot) in
            if snapshot.value as? Bool == true {
                rootViewController.popViewController(animated: true)
                //Remove these observers
                ref.removeAllObservers()
            }
        }
        
        ref.child("didPlayerLeave").observe(.value) { (snapshot) in
            if snapshot.value as? Bool == true {
                //TODO: need to go home
                rootViewController.popViewController(animated: true)
                //Remove these observers
                ref.removeAllObservers()
            }
        }
        
        ref.child("shouldStartGame").observe(.value) { (snapshot) in
            if snapshot.value as? Bool == true {
                rootViewController.pushViewController(vc, animated: true)
            }
        }
        
        //1. Initiate a rematch; 2. Send players back to the appropriate screen; 3. reset game stats
//        ref.child("shouldRematch").observe(.value) { (snapshot) in
//            if snapshot.value as? Bool == true {
//                //Reset game stats
//                RealtimeService.shared.resetGame(completion: { (bool) in
//                    guard bool == true else {return}
//                    rootViewController.popViewController(animated: true)
//                })
//            }
//        }
        
    }
    
    
}
