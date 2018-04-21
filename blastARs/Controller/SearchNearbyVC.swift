//
//  SearchNearbyVC.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/22/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwiftKeychainWrapper

class SearchNearbyVC: UIViewController {
    @IBOutlet weak var loading: UIImageView!
    
    var shouldLoad = true
    let locationManager = CLLocationManager()
    var nibUserDict = [UserButtonView: User]()
    var tap: UITapGestureRecognizer!
    var nearbyUsers = [User]() {
        didSet {
            addUser(user: nearbyUsers.last!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        rotate()
        
        //Unhide back button
        navigationItem.setHidesBackButton(false, animated: true)
        
        //Configure tap recognizer
        tap = UITapGestureRecognizer(target: self, action: #selector(userTapped))
        self.view.addGestureRecognizer(tap)
        //Assign location manager delegate
        locationManager.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    //MARK: Main functions
    func addUser(user: User) {
        //Load nib
        let nib = Bundle.main.loadNibNamed("UserButtonView", owner: self, options: nil)?.first as! UserButtonView
        //Configure with the user to add username
        nib.configure(user: user)
        //Add nib and user to the nibUser dict
        nibUserDict[nib] = user
        //Set frame properties
        let nibHeight: CGFloat = 60
        let padding: CGFloat = 5
        let screenHeight = self.view.frame.height
        let screenWidth = self.view.frame.width
        //Define the pre-animation frame for the nib, which is just below the screen
        let startingFrame = CGRect(x: 0, y: screenHeight + nibHeight, width: screenWidth, height: nibHeight)
        //Initialize post-animation frame
        var endFrame: CGRect!
        //Get total number of users, minus two because current user has already been added and we want PREVIOUS users
        let numUsers = nearbyUsers.count - 1
        //Determine the post-animation y point of the nib based on the number of users already loaded onto the screen
        switch numUsers {
        case 0:
            endFrame = CGRect(x: 0, y: screenHeight - nibHeight, width: screenWidth, height: nibHeight)
        default:
            //Subtract number of users * nib heights * padding in between to get the y
            let y = screenHeight - (CGFloat(numUsers+1) * (nibHeight + padding))
            endFrame = CGRect(x: 0, y: y, width: screenWidth, height: nibHeight)
        }
        nib.frame = startingFrame
        self.view.addSubview(nib)
        slideUp(toFrame: endFrame, forNib: nib)
        
    }
    
    func startGameSetup() {
        
    }
    
    
    //MARK: Selectors
    @objc func userTapped(gesture: UITapGestureRecognizer) {
        let touchLoc = gesture.location(in: self.view)
        for entry in nibUserDict {
            if entry.key.frame.contains(touchLoc) {
                let user2 = entry.value
                // [START]
                //Create instance of user for the current user
                let username = DEFAULTS.string(forKey: USERNAME)
                let uid = KeychainWrapper.standard.string(forKey: KEY_UID)!
                let host = User(userData: ["username": username as Any, "uid": uid as Any])
                let gameId = NSUUID.init().uuidString
                //Set CurrentGame struct static properties
                CurrentGame.gameUid = gameId
                CurrentGame.selfUid = uid
                CurrentGame.opponentUid = user2.uid
                //Create a challenge node in realtime db
                RealtimeService.shared.createChallenge(host: host, user2: user2, gameId: gameId) {
                    GameObserver.shared.observeGameAsHost(gameId: gameId)
                    print("should segue")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
                    let vc = storyboard.instantiateViewController(withIdentifier: "WaitForOpponentVC") as! WaitForOpponentVC
                    let rootViewController = UIApplication.shared.keyWindow?.rootViewController as! UINavigationController
                    rootViewController.pushViewController(vc, animated: true)
                }
                //[END]
            }
        }
    }
    
    //MARK: Animations
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
    
    func slideUp(toFrame frame: CGRect, forNib nib: UserButtonView) {
        //End loading animation after first
        UIView.animate(withDuration: 0.4) {
            nib.frame = frame
        }
    }
}

extension SearchNearbyVC: CLLocationManagerDelegate {
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if let location = locationManager.location {
                RealtimeService.shared.addUserLocation(location: location)
                queryUsers()
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == CLAuthorizationStatus.authorizedWhenInUse, let location = locationManager.location else {return}
        
        RealtimeService.shared.addUserLocation(location: location)
        queryUsers()
        
    }
    
    func queryUsers() {
        guard let latitude = locationManager.location?.coordinate.latitude, let longitude = locationManager.location?.coordinate.longitude else {
            Alert.shared.okAlert(viewController: self, title: "Can't get your location", message: "Please try again!")
            return
        }
        
        let locRef = RealtimeService.shared.REF_USER_LOCATIONS
        let geoFire = GeoFire(firebaseRef: locRef)
        let query = geoFire?.query(at: CLLocation(latitude: latitude, longitude: longitude), withRadius: 2)
        query?.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            guard self.nearbyUsers.count < 5 else {return}
            RealtimeService.shared.getUser(uid: key) { userData in
                let user = User(userData: userData)
                //Don't add current user
                if user.username != DEFAULTS.string(forKey: USERNAME) {
                    self.nearbyUsers.append(user)
                }
            }
        })
        
        query?.observeReady({
            self.shouldLoad = false
        })
    
    }
    
}
