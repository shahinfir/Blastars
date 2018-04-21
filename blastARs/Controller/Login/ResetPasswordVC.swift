//
//  ResetPasswordVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/20/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetPasswordVC: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var resetPasswordBtn: UIButton!
    @IBOutlet weak var emailField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController!.navigationBar.backItem?.title = ""

        //Email keyboard
        emailField.keyboardType = .emailAddress
        
        //"Done" button above keyboard
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        //let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let postButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        toolBar.setItems([postButton], animated: true)
        emailField.inputAccessoryView = toolBar
  
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func restPasswordBtnTapped(_ sender: Any) {
        guard let email = emailField.text else {return}
        guard email != "" else {return}
        
        //Check if email is registered with the app
        //If arr is not empty, email exists. Send password reset email.
        //Else, email is not registered. Don't send password resset email.
        Auth.auth().fetchProviders(forEmail: email) { (arr, error) in
            if error != nil {
                Alert.shared.okAlert(viewController: self, title: "Invalid Email", message: "Please try again with a valid email.")
            } else if arr == nil {
                Alert.shared.okAlert(viewController: self, title: "Email not registered", message: "Sorry, we don't recognize that email.")
            } else {
                Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
                    if error != nil {
                        Alert.shared.okAlert(viewController: self, title: "Something went wrong", message: "Sorry about that. Let's try it one more time.")
                    } else {
                        Alert.shared.okAlert(viewController: self, title: "Check your inbox", message: "We've sent you instructions on how to reset your password.")
                    }
                })
            }
        }
    }
    
    //Keyboard "done" selector
    @objc func doneTapped() {
        view.endEditing(true)
    }



}

