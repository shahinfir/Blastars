//
//  PasswordVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/19/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class PasswordVC: UIViewController {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
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
      
        //"Done" button above keyboard
        let toolBar = UIToolbar()
        toolBar.sizeToFit()

        let postButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        toolBar.setItems([postButton], animated: true)
        passwordField.inputAccessoryView = toolBar
        confirmPasswordField.inputAccessoryView = toolBar
        
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
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        guard let password = passwordField.text, let confirmPassword = confirmPasswordField.text, _email != nil else {
            return
        }
       
        //TODO: password validation with uppercase, lowercase, special character, spaces, etc
        
        //Check that password is not an empty string
        if password == "" {
            Alert.shared.okAlert(viewController: self, title: "Password", message: "Please enter a valid password.")
        //Check that password is at least 6 characters in length
        } else if password.count < 6 {
            Alert.shared.okAlert(viewController: self, title: "Password", message: "Password must be at least 6 characters.")
        //Check that passwords match
        } else if password != confirmPassword {
            Alert.shared.okAlert(viewController: self, title: "Passwords don't match", message: "Please fix before continuing.")
        } else {
            Auth.auth().createUser(withEmail: _email, password: password, completion: { (user, error) in
                if error != nil {
                    if error?.localizedDescription == "The email address is already in use by another account." {
                        Alert.shared.okAlert(viewController: self, title: "Email already in use", message: "Please sign up with a different email address")
                    } else {
                        Alert.shared.okAlert(viewController: self, title: "Email", message: "Please sign up with a valid email address")
                    }
                } else {
                    if let user = user {
                        self.completeSignIn(id: user.uid, email: self._email, provider: user.providerID)
                    }
                }
            })
        }
    }

    
    func completeSignIn(id: String, email: String, provider: String) {
        //Set uid to the keychain
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        CurrentUser.uid = id
        //Post to firebase
        let userData = ["email": email as AnyObject,
                        "provider": provider as AnyObject,
                        "uid": id as AnyObject]
        
        //Create firestore user
        FirestoreService.shared.createFirestoreUser(uid: id, userData: userData)
        //Create realtime db user
        RealtimeService.shared.addPrivateData(uid: id, privateData: userData)
        
        //Segue to username
        performSegue(withIdentifier: "toUsername", sender: _email)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UsernameVC {
            if let email = sender as? String {
                destination.email = email
            }
        }
    }

    

}
