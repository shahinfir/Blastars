//
//  GuestUsernameVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 4/2/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class GuestUsernameVC: UIViewController {

   
    @IBOutlet weak var usernameField: UITextField!
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //IMPORTANT: Give the user a uid because they are not getting one from auth, as this is a guest login. Add to keychain wrapper so database calls work properly. And set to CurrentUser.uid so observers are called.
        uid = NSUUID.init().uuidString
        KeychainWrapper.standard.set(uid, forKey: KEY_UID)
        CurrentUser.uid = uid
        
        
        //Autofill username field with previous username, if exists
        if let username = DEFAULTS.string(forKey: GUEST_USERNAME) {
            usernameField.text = username
        }
        
        //Unhide nav bar
        navigationItem.setHidesBackButton(false, animated: true)

        //"Done" button above keyboard
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        //let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let postButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        toolBar.setItems([postButton], animated: true)
        usernameField.inputAccessoryView = toolBar
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func finishBtnTapped(_ sender: Any) {
        guard let username = usernameField.text else {return}
        guard username.filter({$0 != " "}) != "" else {
            Alert.shared.okAlert(viewController: self, title: "Identify yourself!", message: "Pick a username before continuing.")
            return
        }
        guard !username.contains(" ") else {
            Alert.shared.okAlert(viewController: self, title: "", message: "No spaces please!")
            return
        }
        
        //Get documents where the username_lowercased is equal to current user's username.lowercased()
        let query = FirestoreService.shared.REF_USERS.whereField("username_lowercased", isEqualTo: username.lowercased())
        
        //If no document hits in querySnapshot, username does not exist and is valid for use
        //Else, username already exists and user must pick new username
        query.getDocuments { (querySnapshot, error) in
            guard error == nil, let query = querySnapshot else {return}
            
            if query.count == 0 {
                //Post 2 versions of current user's username:
                //1. username as entered by user and
                //2. lowercased username, for comparison purposes
                let userData: [String:Any] = ["username": username, "username_lowercased": username.lowercased(), "uid": self.uid]
                FirestoreService.shared.createFirestoreUser(uid: self.uid, userData: userData)
                    
                //Add to realtime db
                let publicData = ["username": username, "username_lowercased": username.lowercased(), "uid": CurrentUser.uid]
                RealtimeService.shared.addPublicData(publicData: publicData)
                
                //Set username to user defaults
                DEFAULTS.set(username, forKey: USERNAME)
                //Also set for key GUEST_USERNAME
                DEFAULTS.set(username, forKey: GUEST_USERNAME)
                
                //Go to main menu
                self.performSegue(withIdentifier: "toMain", sender: nil)
        
            } else if query.count > 0 {
                //Log user in if username is already in keychain
                if username == DEFAULTS.string(forKey: GUEST_USERNAME) {
                    //Get uid
                    let doc = query.documents.first
                    guard let data = doc?.data() else {return}
                    guard let uid = data["uid"] as? String else {return}
                    CurrentUser.uid = uid
                    KeychainWrapper.standard.set(uid, forKey: KEY_UID)
                    KeychainWrapper.standard.set(username, forKey: USERNAME)
                    //Go to main menu
                    self.performSegue(withIdentifier: "toMain", sender: nil)
                } else {
                     Alert.shared.okAlert(viewController: self, title: "Username taken", message: "Sorry about that! Try again with a different username")
                }
            }
        }
    }
    
    //Keyboard "done" selector
    @objc func doneTapped() {
        view.endEditing(true)
        //If the view has been shifted up, shift back down
        if self.view.frame.origin.y != 0 {
            AnimationService.shared.shiftViewDown(vc: self)
        }
    }
    

}
