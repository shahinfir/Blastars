//
//  MainMenuVC.swift
//  AR-Cloud-Pong
//
//  Created by Shahin Firouzbakht on 3/14/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class MainMenuVC: UIViewController {
    
    var audioPlayer = AVAudioPlayer()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        //Assign location manager delegate
        locationManager.delegate = self
        
        //Play background audio
        playAudio(path: MAIN_MENU!)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
         locationAuthStatus()
    }
    
    
    @IBAction func battleTapped(_ sender: Any) {
        audioPlayer.stop()
        playAudio(path: BATTLE_MENU_CLICK!)
    }
    
    @IBAction func tutorialTapped(_ sender: Any) {
        audioPlayer.stop()
        playAudio(path: TUTORIAL_START!)
    }
    func playAudio(path: String) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: path))
        }
        catch {
            print("Error playing audio file: \(error.localizedDescription)")
        }
        audioPlayer.play()
    }

   
}

extension MainMenuVC: CLLocationManagerDelegate {
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if let location = locationManager.location {
                RealtimeService.shared.addUserLocation(location: location)
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == CLAuthorizationStatus.authorizedWhenInUse, let location = locationManager.location else {return}
        
            RealtimeService.shared.addUserLocation(location: location)

    }
    
}
