//
//  EmailVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/19/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import Firebase

class EmailVC: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var lineUnderTextField: UIView!
    @IBOutlet weak var continueBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Email keyboard
        emailField.keyboardType = .emailAddress
        
        //"Done" button above keyboard
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        //let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let postButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        toolBar.setItems([postButton], animated: true)
        emailField.inputAccessoryView = toolBar
        
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
        guard let email = emailField.text else {return}
        guard isValid(email) == true else {
            Alert.shared.okAlert(viewController: self, title: "Invalid Email", message: "Please provide a valid email and try again!")
            return
        }
        
        //Check if email already exists by fetching providers.
        //If arr is not empty, the email already exists.
        Auth.auth().fetchProviders(forEmail: email) { (arr, error) in
            if error != nil {
                Alert.shared.okAlert(viewController: self, title: "Invalid Email", message: "Please provide a valid email and try again")
            } else if arr != nil {
                Alert.shared.okAlert(viewController: self, title: "Email already in use", message: "Please choose another email")
            } else {
                self.performSegue(withIdentifier: "toPassword", sender: email)
            }
        }
    
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PasswordVC {
            if let email = sender as? String {
                destination.email = email
            }
        }
    }
    
    //Regex to check for proper email format.
    func isValid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
       
        return emailTest.evaluate(with: email)
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
