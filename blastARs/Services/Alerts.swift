//
//  File.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/20/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit


class Alert {
    
   static let shared = Alert()
    
    func okAlert(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func endGameAlert(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    
        alert.addAction(UIAlertAction(title: "Leave", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            //Leave the game
            RealtimeService.shared.leaveGame()
            
        }))
    
        alert.addAction(UIAlertAction(title: "Rematch", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            //Initiate a rematch
            RealtimeService.shared.rematch()
            
        }))
        
        viewController.present(alert, animated: true, completion: nil)
    
    }
    
   
    
}


