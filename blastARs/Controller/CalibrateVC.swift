//
//  CalibrateVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/24/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class CalibrateVC: UIViewController {
    
    @IBOutlet weak var readyBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var loading: UIImageView!
    
    var player: AVPlayer!
    var shouldLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        //Start load animation
        rotate()

        continueBtn.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        readyBtn.isHidden = false
        readyBtn.isEnabled = true
        
//        guard let path = Bundle.main.path(forResource: "instructions", ofType:"mp4") else {
//            print("video not found")
//            return
//        }
        if let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/ar-cloud-pong.appspot.com/o/Video%2Finstructions.mp4?alt=media&token=a508e729-a2d2-4bbf-b953-6a2944177721") {
            
            player = AVPlayer(url: url)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = videoView.bounds
            videoView.layer.addSublayer(playerLayer)
            player.play()
            
            //Stop loading animation
            shouldLoad = false
            
            //Set notification for when video has ended
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,object: player.currentItem)
            
        }
        
       
    }
    
    //Play video again when video ends (loop it)
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        player.seek(to: kCMTimeZero)
        player.play()
    }
    

    
    @IBAction func readyBtnTapped(_ sender: Any) {
        readyBtn.isHidden = true
        continueBtn.isEnabled = true
    }
    @IBAction func continueBtnTapped(_ sender: Any) {
        continueBtn.isEnabled = false
        //Start the game
        RealtimeService.shared.startGame() { bool in
            if bool == true {
                self.performSegue(withIdentifier: "toBattle", sender: nil)
            } else {
                Alert.shared.okAlert(viewController: self, title: "Oops", message: "There was an error initializing the game. Try again!")
                self.continueBtn.isEnabled = true
            }
        }
    }
    
    
    func rotate() {
        guard shouldLoad == true else {
            loading.removeFromSuperview()
            return
        }
        
        UIView.animate(withDuration: 0.75, animations: {
            self.loading.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            self.loading.transform = CGAffineTransform(rotationAngle: 2*CGFloat.pi)
        })
        { (anyValue) in
            self.rotate()
        }
    }
    
    

   

}
