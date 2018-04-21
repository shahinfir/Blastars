//
//  SettingsVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/31/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FirebaseAuth

class SettingsVC: UIViewController {
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Unhide back button
        navigationItem.setHidesBackButton(false, animated: true)
        
        //Get username from defaults and email from Auth
        if let username = DEFAULTS.string(forKey: USERNAME), let email = Auth.auth().currentUser?.email {
            usernameLbl.text = username
            emailLbl.text = email
        } else if let username = DEFAULTS.string(forKey: USERNAME) {
            usernameLbl.text = username
        }
        
        //"Done" button above keyboard
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let postButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        toolBar.setItems([postButton], animated: true)
        textView.inputAccessoryView = toolBar
     
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    @IBAction func submitBtnTapped(_ sender: Any) {
        guard let text = textView.text else {return}
        guard text != "Leave feedback...", text != "", text.filter({$0 != " "}) != "" else {
            Alert.shared.okAlert(viewController: self, title: "Tell Us Something", message: "Give us some feedback before submitting")
            return
        }
        
        RealtimeService.shared.leaveFeedback(text: text) { success in
            if success == true {
                Alert.shared.okAlert(viewController: self, title: "Thank You", message: "We truly appreciate your feedback!")
            } else {
                Alert.shared.okAlert(viewController: self, title: "Oops", message: "Something went wrong. Try again!")
            }
        }
    }
    
    @IBAction func logoutBtnTapped(_ sender: Any) {
        _ = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! Auth.auth().signOut()
            
        for vc in navigationController!.viewControllers {
            if vc.isKind(of: HomeVC.self) {
                navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    @objc func doneTapped() {
        view.endEditing(true)
    }

}

extension SettingsVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Leave feedback..." {
            textView.text = ""
        }
    }
}
