//
//  RealtimeService.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/12/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper


let RT_BASE = Database.database().reference()

class RealtimeService {
    
    private init() {}
    static let shared = RealtimeService()
    
    //Realtime database references
    private var _REF_BASE = RT_BASE
    private var _REF_PLAYER_ONE = RT_BASE.child("playerOne")
    private var _REF_PLAYER_TWO = RT_BASE.child("playerTwo")
    private var _REF_BALL = RT_BASE.child("ball")
    private var _REF_USERS_PRIVATE = RT_BASE.child("users_private")
    private var _REF_USERS_PUBLIC = RT_BASE.child("users_public")
    private var _REF_USER_LOCATIONS = RT_BASE.child("userLocations")
    private var _REF_CHALLENGES = RT_BASE.child("challenges")
    
    
    //Realtime database
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USER_LOCATIONS: DatabaseReference {
        return _REF_USER_LOCATIONS
    }
    
    var REF_PLAYER_ONE: DatabaseReference {
        return _REF_PLAYER_ONE
    }
    
    var REF_PLAYER_TWO: DatabaseReference {
        return _REF_PLAYER_TWO
    }
    
    var REF_BALL: DatabaseReference {
        return _REF_BALL
    }
    
    var REF_CHALLENGES: DatabaseReference {
        return _REF_CHALLENGES
    }
    
    var REF_USERS_PRIVATE: DatabaseReference {
        return _REF_USERS_PRIVATE
    }
    
    var REF_USERS_PUBLIC: DatabaseReference {
        return _REF_USERS_PUBLIC
    }
    
    var REF_CURRENT_USER_PRIVATE: DatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS_PRIVATE.child(uid!)
        return user
    }
    
    var REF_CURRENT_USER_PUBLIC: DatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS_PUBLIC.child(uid!)
        return user
    }
    
    var REF_CHALLENGED_ME: DatabaseReference {
        return REF_CURRENT_USER_PUBLIC.child("challengeId")
    }
    
    var REF_FEEDBACK: DatabaseReference {
        return REF_CURRENT_USER_PRIVATE.child("feedback")
    }
    

    /**
    Adds user location to the realtime db
     - Parameter location: the user's current location
    */
    func addUserLocation(location: CLLocation) {
        guard let uid = KeychainWrapper.standard.string(forKey: KEY_UID) else {
            print("SHAHIN: failed kehychain guard")
            return}
        
        print("SHAHIN: adduserlocation proper")
        let geoFire = GeoFire(firebaseRef: REF_USER_LOCATIONS)
        geoFire?.setLocation(location, forKey: uid)
        
    }
    func setPlayerStatus(selfRef: DatabaseReference, opponentRef: DatabaseReference) {
        //Set health and mana
        selfRef.child("health").setValue(5)
      
    }
    
    func getUsername(completion: @escaping(String) -> Void) {
        REF_CURRENT_USER_PUBLIC.child("username").observe(.value) { (snapshot) in
            if let username = snapshot.value as? String {
                print("retreiving username: \(username)")
                completion(username)
            }
        }
    }
    
    func getUser(uid: String, completion: @escaping(Dictionary<String, Any>) -> Void) {
        RealtimeService.shared._REF_USERS_PUBLIC.child(uid).observe(.value) { (snapshot) in
            guard let userData = snapshot.value as? Dictionary<String, Any> else {return}
            
            completion(userData)
        }
    }
    
    func addGameStats() {
        
    }
    
    func adjustSelfHealth(selfRef: DatabaseReference, health: Int) { //Adjusts current user's health
        selfRef.child("health").setValue(health)
    }
    
    func adjustOpponentHealth(opponentRef: DatabaseReference, opponentHealth: Int) {
        opponentRef.child("health").setValue(opponentHealth)
    }
    
    func addPrivateData(uid: String, privateData: Dictionary<String, Any>) {
        REF_USERS_PRIVATE.child(uid).setValue(privateData)
    }
    
    func addPublicData(publicData: Dictionary<String, Any>) {
        REF_CURRENT_USER_PUBLIC.setValue(publicData)
    }
    
    
    
    func createChallenge(host: User, user2: User, gameId: String, completion: @escaping() -> ()) {
        print("BUG: host uid: \(host.uid)")
        print("BUG: host username: \(host.username)")
        print("BUG: user2 uid: \(user2.uid)")
        print("BUG: user2 username: \(user2.username)")
        
        //Write to challenges branch
        let challengeData: [String: Any] = ["hostUid": host.uid,
                                            "hostUsername": host.username,
                                            "user2Uid": user2.uid,
                                            "user2Username": user2.username,
                                            "didPlayerLeave": false,
                                            "didAccept": false,
                                            "didDecline": false,
                                            "shouldStartGame": false,
                                            "shouldRematch": false]

        
        REF_CHALLENGES.child(gameId).setValue(challengeData) { (error, ref) in
            if error == nil {
                //Set other user's "challengdMe" field to the the gameID
                //Allows other user to point to the correct challenge in challenges branch
                self.REF_USERS_PUBLIC.child(user2.uid).child("challengeId").setValue(gameId, withCompletionBlock: { (error, ref) in
                    if error == nil {
                        completion()
                    }
                })
            }
        }
    }
    
    //Set didAccept field in challenge node to true. Observer will pick this up and segue to next screen.
    func acceptChallenge() {
        REF_CHALLENGES.child(CurrentGame.gameUid).child("didAccept").setValue(true)
    }
    
    //Set didDecline field in challenge node to true. Observer will pick this up and cancel game.
    func declineChallenge() {
        REF_CHALLENGES.child(CurrentGame.gameUid).child("didDecline").setValue(true)
    }
    
    //Sets shouldStartGame field to true. Observer will pick this up and begin the game
    func startGame(completion: @escaping(Bool) -> Void) {
        let gameStats: [String: Any] = [CurrentGame.selfUid:       ["health": 5,
                                                                    "xPosition": 0,
                                                                    "zPosition": 0,
                                                                    "boltsFired": true],
                                        CurrentGame.opponentUid:   ["health": 5,
                                                                    "xPosition": 0,
                                                                    "zPosition": 0,
                                                                    "boltsFired": true],
                                        "shouldStartGame":          true]
        
        REF_CHALLENGES.child(CurrentGame.gameUid).updateChildValues(gameStats) { (error, ref) in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func leaveFeedback(text: String, completion: @escaping(Bool) -> Void) {
        REF_FEEDBACK.childByAutoId().setValue(text) { (error, ref) in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    
    //For rematch
//    func resetGame(completion: @escaping(Bool) -> Void) {
//        let gameStats: [String: Any] = ["shouldStartGame": false,
//                                        "shouldRematch":   false]
//
//        REF_CHALLENGES.child(CurrentGame.gameUid).updateChildValues(gameStats) { (error, ref) in
//            if error == nil {
//                completion(true)
//            } else {
//                completion(false)
//            }
//        }
//    }
    
    func leaveGame() {
        REF_CHALLENGES.child(CurrentGame.gameUid).child("didPlayerLeave").setValue(true)
    }
    
    func rematch() {
        REF_CHALLENGES.child(CurrentGame.gameUid).child("shouldRematch").setValue(true)
    }


}
