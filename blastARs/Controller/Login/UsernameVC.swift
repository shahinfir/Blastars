//
//  UsernameVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/19/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import Firebase

class UsernameVC: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var lineUnderTextField: UIView!
    
    private var _email: String!
    var email: String {
        get {
            return _email
        } set {
            _email = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Remove navigation bar
        //Users cannot go back at this point
        navigationController?.setNavigationBarHidden(true, animated: true)
      
        //"Done" button above keyboard
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        //let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let postButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        toolBar.setItems([postButton], animated: true)
        usernameField.inputAccessoryView = toolBar
        
        //Get keyboard height
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        //If the view has been shifted up, shift back down
        if self.view.frame.origin.y != 0 {
            AnimationService.shared.shiftViewDown(vc: self)
        }
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
                let userData: [String:Any] = ["username": username, "username_lowercased": username.lowercased()]
                FirestoreService.shared.addUserDetail(userData: userData) {
                    self.performSegue(withIdentifier: "toMain", sender: nil)
                    
                //Add to realtime db
                    let publicData = ["username": username, "username_lowercased": username.lowercased(), "uid": CurrentUser.uid]
                RealtimeService.shared.addPublicData(publicData: publicData)
                    
                //Set username to user defaults
                    //TODO: this needs to be on login in case of signing into different account or deleting/reinstalling app
                    DEFAULTS.set(username, forKey: USERNAME)
                }
            } else if query.count > 0 {
                Alert.shared.okAlert(viewController: self, title: "Username taken", message: "Sorry about that! Try again with a different username")
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
    
    //Keyboard will show notification
    @objc func keyboardWillShow(notification: NSNotification) {
        guard view.frame.origin.y == 0 else {return}
        
        //TODO: Configure this specifically for the iPhone SE, on all necessary screens
        
        NotificationService.shared.shiftKeyboardUp(vc: self, bottomElement: lineUnderTextField, notification: notification)
        
    }

  

}
