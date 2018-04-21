//
//  ChallengedVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/22/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit

class ChallengedVC: UIViewController {
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var loading: UIImageView!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var declineBtn: UIButton!
    @IBOutlet weak var challenegedLbl: UILabel!
    
    var shouldLoad = true
    var opponentUsername: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide back button
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        //Set all elements hidden until username loads
        challenegedLbl.isHidden = true
        acceptBtn.isHidden = true
        declineBtn.isHidden = true
        
        //Start loading animation
        rotate()
        
        RealtimeService.shared.REF_CHALLENGES.child(CurrentGame.gameUid).observeSingleEvent(of: .value) { (snapshot) in
            if let gameData = snapshot.value as? Dictionary<String, Any> {
                if let name = gameData["hostUsername"] as?  String{
                    self.opponentUsername = name
                    
                    self.usernameLbl.text = self.opponentUsername!
                    
                    //Stop loading animation
                    self.loading.isHidden = true
                    self.shouldLoad = false

                    //Unhide all elements
                    self.challenegedLbl.isHidden = false
                    self.acceptBtn.isHidden = false
                    self.declineBtn.isHidden = false
                }
            }
        }
    }
    
    @IBAction func acceptBtnTapped(_ sender: Any) {
        RealtimeService.shared.acceptChallenge()
        performSegue(withIdentifier: "toInstructions", sender: opponentUsername)
    }
    
    @IBAction func declineBtnTapped(_ sender: Any) {
        RealtimeService.shared.declineChallenge()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? WaitForInstructionsVC {
            if let opponentUsername = sender as? String {
                destination.opponentUsername = opponentUsername
            }
        }
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

}
