//
//  WaitForOpponentVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/23/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit

class WaitForOpponentVC: UIViewController {
    
    @IBOutlet weak var waitLbl: UILabel!
    @IBOutlet weak var loading: UIImageView!
    
    var shouldLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Start loading animation
        rotate()
       
    }
    
    func rotate() {
        guard shouldLoad == true else {return}
        
        UIView.animate(withDuration: 0.75, animations: {
            self.loading.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            self.loading.transform = CGAffineTransform(rotationAngle: 2*CGFloat.pi)
        })
        { (anyValue) in
            self.rotate()
        }
    }

    //waiting for opponent
    //Set listener to the game here
    //If accept = true -> go to instructions page
    //IF decline == true -> display user has delince -> error message -> back to home

}
