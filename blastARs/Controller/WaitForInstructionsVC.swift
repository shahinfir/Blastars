//
//  WaitForInstructionsVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/24/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit

class WaitForInstructionsVC: UIViewController {
    
    @IBOutlet weak var usernameLbl: UILabel!

    private var _opponentUsername: String!
    var opponentUsername: String {
        get {
            return _opponentUsername
        } set {
            _opponentUsername = newValue
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if _opponentUsername != nil {
            usernameLbl.text = _opponentUsername
        } else {
            usernameLbl.text = "Opponent"
        }
        
    }



}
