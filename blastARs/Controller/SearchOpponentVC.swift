//
//  SearchOpponentVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/22/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FirebaseAuth

class SearchOpponentVC: UIViewController {
    @IBOutlet weak var usernameField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //"Done" button above keyboard
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let postButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        toolBar.setItems([postButton], animated: true)
        usernameField.inputAccessoryView = toolBar

        //Unhide back button
        navigationItem.setHidesBackButton(false, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func doneTapped() {
        view.endEditing(true)
    }
    
    
    @IBAction func goBtnTapped(_ sender: Any) {
        guard let search = usernameField.text?.lowercased() else {
           //error message
            return
        }
        
        RealtimeService.shared.REF_USERS_PUBLIC.queryOrdered(byChild: "username_lowercased").queryEqual(toValue: search).observeSingleEvent(of: .value) { (snapshot) in
            //todo: user does not exist
            //todo: guards
            
            if let snap = snapshot.value as? Dictionary<String, Any>  {
                print("got snap")
                if let user = snap.first {
                    print("got user")
                    if let userDict = user.value as? Dictionary<String, Any> {
                        print("got dict")
                        if userDict["username"] as? String != DEFAULTS.string(forKey: USERNAME) {
                            print("BUG: user dict is \(userDict)")
                            //Create instance of user for the user that is being challenged
                            let user2 = User(userData: userDict)
                            //Create instance of user for the current user
                            let username = DEFAULTS.string(forKey: USERNAME)
                            let uid = KeychainWrapper.standard.string(forKey: KEY_UID)!
                            let host = User(userData: ["username": username as Any, "uid": uid as Any])
                            let gameId = NSUUID.init().uuidString
                            //Set CurrentGame struct static properties
                            CurrentGame.gameUid = gameId
                            CurrentGame.selfUid = uid
                            if let opponentUid = userDict["uid"] as? String {
                                CurrentGame.opponentUid = opponentUid
                                print("BUG: opponent uid is \(CurrentGame.opponentUid)")
                            }
                            //Create a challenge node in realtime db
                            RealtimeService.shared.createChallenge(host: host, user2: user2, gameId: gameId) {
                                GameObserver.shared.observeGameAsHost(gameId: gameId)
                                
                                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                                let vc = storyboard.instantiateViewController(withIdentifier: "WaitForOpponentVC") as! WaitForOpponentVC
                                let rootViewController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
                                rootViewController.pushViewController(vc, animated: true)
                            
                            }
                        }
                    }
                }
            }
        }
    }

}
