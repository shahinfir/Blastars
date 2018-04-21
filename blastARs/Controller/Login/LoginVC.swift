//
//  LoginVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/20/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loginBtn.isEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func forgotPasswordBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "toResetPassword", sender: nil)
    }

    
    @IBAction func loginBtnTapped(_ sender: Any) {
        loginBtn.isEnabled = false
        
        guard let email = emailField.text, let password = passwordField.text else {
            loginBtn.isEnabled = true
            return
        }
        guard email.filter({$0 != " "}) != "", password.filter({$0 != " "}) != "" else {
            Alert.shared.okAlert(viewController: self, title: "Missing email or password", message: "Please enter both to login.")
            loginBtn.isEnabled = true
            return
        }
        
        //Use auth object to attempt to sign in user
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            guard error == nil, let user = user else {
                Alert.shared.okAlert(viewController: self, title: "Uh oh", message: "Invalid login credentials. Try again.")
                self.loginBtn.isEnabled = true
                return
            }
            
            CurrentUser.uid = user.uid
            KeychainWrapper.standard.set(user.uid, forKey: KEY_UID)
            
            RealtimeService.shared.getUsername() { username in
                DEFAULTS.setValue(username, forKey: USERNAME)
                KeychainWrapper.standard.set(username, forKey: USERNAME)
                self.performSegue(withIdentifier: "toMain", sender: nil)
            }
            
            
        })
        
    }
    

   

}
