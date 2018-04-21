//
//  NotificationService.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/21/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit

class NotificationService {
    
    private init() {}
    static let shared = NotificationService()
    
    func shiftKeyboardUp(vc: UIViewController, bottomElement: UIView, notification: NSNotification) {
    
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print("shahin keyboard height is \(keyboardHeight)")
            //Height of view
            let viewHeight = vc.view.frame.height
            
            //Get position of line underneath text field
            let lineY = bottomElement.frame.origin.y
            let lineHeight = bottomElement.frame.height
            
            //Shift keyboard up if keyboard covers line under text field
            if keyboardHeight > viewHeight - (lineY + lineHeight) {
                print("shahin should shift")
                let yBottom = bottomElement.frame.origin.y + bottomElement.frame.height
                vc.view.frame.origin.y -= (yBottom - (vc.view.frame.height - keyboardHeight) + 10)
            } else {
                print("shahin shouldn't shift")
            }
            
        }
    }

}
