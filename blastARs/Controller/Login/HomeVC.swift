//
//  HomeVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/19/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper

class HomeVC: UIViewController {
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationController?.setBarTranslucent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser {
            
            CurrentUser.uid = user.uid
            KeychainWrapper.standard.set(user.uid, forKey: KEY_UID)
            
            RealtimeService.shared.getUsername() { username in
                DEFAULTS.setValue(username, forKey: USERNAME)
                KeychainWrapper.standard.set(username, forKey: USERNAME)
                self.performSegue(withIdentifier: "toMain", sender: nil)
            }
        }
    }

  

}
