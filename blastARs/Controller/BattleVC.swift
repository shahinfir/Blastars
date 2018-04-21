//
//  BattleVC.swift
//  AR-Cloud-Pong
//
//  Created by Shahin Firouzbakht on 3/12/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import Firebase
import AVFoundation

class BattleVC: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var reticle: UIImageView!
    @IBOutlet weak var manaImg: UIImageView!
    @IBOutlet weak var healthBar: UIImageView!
    @IBOutlet weak var manaBar: UIImageView!
    @IBOutlet weak var healBtn: UIButton!
    @IBOutlet weak var shootBtn: UIButton!
    @IBOutlet weak var countdownLbl: UILabel!
    @IBOutlet weak var instructionsLbl: UILabel!

    
    //TODO: reset database in between games
    
    var selfHealth = 5
    var selfMana = 5
    var opponentHealth = 5
    var objectArray: [String] = ["banana", "backpack", "can opener, tin opener", "monitor", "sleeping bag", "mouse, computer mouse"]
    var opponentNode: SCNNode!
    var selfNode: SCNNode!
    var opponentRef: DatabaseReference!
    var selfRef: DatabaseReference!
    var nodes = Nodes()
    var backgroundPlayer = AVAudioPlayer()
    var foregroundPlayer = AVAudioPlayer()
    var countdown = 10
    var test = 0
    var hitLanded: HitLandedIndicator!
    var hurt: HurtIndicator!
    
    
    //Bool to determine when didUpdate frame should start sending position data to firebase
    var shouldTrackSelf = false
    
    var shouldRecognizeImg = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        
        //Hide back button
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        //Add long press to energy mutation button (obj recognition)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(manaLongPressed))
        manaImg.addGestureRecognizer(longPress)
        
        //Start background audio
        playBackground(path: BATTLE_BACKGROUND!)
        
        //Hide bottom buttons & reticle until countdown is finished.
        shootBtn.isHidden = true
        healBtn.isHidden = true
        manaImg.isHidden = true
        reticle.isHidden = true
        
        //Configure the indicators
        
        hitLanded = HitLandedIndicator(frame: CGRect(x: 53.0, y: 224, width: 81, height: 40))
        hurt = HurtIndicator(frame: sceneView.frame)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.scene.rootNode.name = "root"
        
        createSelfAndOpponentNodes()
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(displayCountdown), userInfo: nil, repeats: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func displayCountdown(sender: Timer) {
        guard countdown > 0 else {
            sender.invalidate()
            return
        }
        
        countdown -= 1
        
        if countdown == 5 {
            instructionsLbl.text = "Spread out and prepare for battle!"
            instructionsLbl.textColor = UIColor.yellow
        }
        
        if countdown == 0 {
            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(removeLabels), userInfo: nil, repeats: false)
            countdownLbl.text = "GO!"
            countdownLbl.textColor = UIColor.green
            instructionsLbl.isHidden = true
            shootBtn.isHidden = false
            healBtn.isHidden = false
            manaImg.isHidden = false
        } else {
            countdownLbl.text = String(countdown)
        }
    }
    
    @objc func removeLabels() {
        countdownLbl.removeFromSuperview()
        instructionsLbl.removeFromSuperview()
        reticle.isHidden = false
    }
    
    func createSelfAndOpponentNodes() {
    
        sceneView.scene.rootNode.eulerAngles.y = (sceneView.pointOfView?.eulerAngles.y)! //Alight root node rotation around the y axis with that of user's pov
        
        
        //Opponent health node
        opponentNode = OpponentNode(sceneView: sceneView)
        let opponentHealthNode = HealthBarNode()
        //Place opponent health bar above tracking node, as child of tracking node
        opponentNode.addChildNode(opponentHealthNode)
  
 
        selfNode = SelfNode(sceneView: sceneView)
  
        
        shouldTrackSelf = true
        
        //Start getting other user location data
        getLocationData()
        
        //Observe opponent health
        CurrentGame.opponentRef.child("health").observe(.value) { (snapshot) in
            if let health = snapshot.value as? Int {
                self.opponentHealth = health
                if self.opponentHealth >= 0 && self.opponentHealth <= 5 {
                    opponentHealthNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/\(self.opponentHealth)health.png")
                }
                if health <= 0 {
                    self.backgroundPlayer.stop()
                    self.playForeground(path: VICTORY!)
                    Alert.shared.okAlert(viewController: self, title: "VICTORY", message: "Congratuations on saving your planet!")
                }
            }
        }
        
        //Set observer for self health
        CurrentGame.selfRef.child("health").observe(.value) { (snapshot) in
            if let health = snapshot.value as? Int {
                if health < self.selfHealth {
                    self.playForeground(path: GETTING_HIT!)
                    //Display got hurt indicator
                    self.sceneView.addSubview(self.hurt)
                    Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.removeHurtIndicator), userInfo: nil, repeats: false)
                }
                self.selfHealth = health
                if self.opponentHealth >= 0 && self.opponentHealth <= 5 {
                    self.changeBarImage(imageView: self.healthBar, status: self.selfHealth, manaOrHealth: "health")
                }
                if health <= 0 {
                    self.backgroundPlayer.stop()
                    self.playForeground(path: DEFEAT!)
                    Alert.shared.okAlert(viewController: self, title: "DEFEAT", message: "Best of luck next time!")
                }
            }
        }
        
        //Set observer for opponent bolts fired
        CurrentGame.opponentRef.child("boltsFired").observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Double> {
                print("direction dict is \(dict)")
                self.getShotAt(directionDict: dict)
            }
        }
        
        
    }
    
    //Change health or mana bar image based on health/mana status at time of calling
    func changeBarImage(imageView: UIImageView, status: Int, manaOrHealth: String) {
        imageView.image = UIImage(named: "\(status)\(manaOrHealth)")
    }
    
    //Animate shot coming toward user
    func getShotAt(directionDict: Dictionary<String, Double>) {
        
        //MARK: POTENTIAL GAME OBJECT
        let lightningNode = nodes.lightningBolt()
        lightningNode.position = SCNVector3(0,0,0)
        let direction = SCNVector3(Float(directionDict["directionX"]!) * -1.0, Float(directionDict["directionY"]!), Float(directionDict["directionZ"]!) * -1.0)
        
        lightningNode.physicsBody?.applyForce(direction, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(lightningNode)
    }
    
    //Track opponents x and z positions relative to their self reference node
    func getLocationData() {
        
        CurrentGame.opponentRef.child("zPosition").observe(.value) { (snapshot) in
            if let z = snapshot.value as? Float {
                self.opponentNode.position.z = -z
            }
        }
        
        CurrentGame.opponentRef.child("xPosition").observe(.value) { (snapshot) in
            if let x = snapshot.value as? Float {
                self.opponentNode.position.x = -x
            }
        }
   
        
    }


    @IBAction func shootTapped(_ sender: Any) {
        guard selfMana > 0 else {
            playForeground(path: NO_MANA!)
            return
        }
        
        playForeground(path: LIGHTNING_BOLT!)
        
        //Decrement mana
        selfMana -= 1
        //Adjust mana status image
        changeBarImage(imageView: manaBar, status: selfMana, manaOrHealth: "mana")
     
        //MARK: POTENTIAL GAME OBJECT
        //Push lightning node toward current opponent tracking node
        let lightningNode = nodes.lightningBolt()
        let positionData = determineBoltPosition()
        lightningNode.position = positionData.1
        let direction = positionData.0
        lightningNode.physicsBody?.applyForce(direction, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(lightningNode)
        
        //selfRef.child("boltsFired").childByAutoId().setValue(["directionX": Double(direction.x), "directionY": Double(direction.y), "directionZ": Double(direction.z)])
        CurrentGame.selfRef.child("boltsFired").childByAutoId().setValue(["directionX": Double(direction.x), "directionY": Double(direction.y), "directionZ": Double(direction.z)])
    }
   
    //Add health only if health is not full and user has mana available
    @IBAction func healTapped(_ sender: Any) {
        guard selfHealth < 5 else {
            playForeground(path: NO_MANA!)
            return
        }
        
        if selfMana > 0 && selfMana <= 5 {
            playForeground(path: HEALTH_REGEN!)
            selfHealth += 1
            selfMana -= 1
            //RealtimeService.shared.adjustSelfHealth(selfRef: selfRef, health: selfHealth)
            CurrentGame.selfRef.updateChildValues(["health": selfHealth])
            changeBarImage(imageView: manaBar, status: selfMana, manaOrHealth: "mana")
        } else {
            playForeground(path: NO_MANA!)
        }
        
        
    }
    
    
    //Back to home
    @IBAction func homeTapped(_ sender: Any) {
        backgroundPlayer.stop()
        for vc in navigationController!.viewControllers {
            if vc.isKind(of: MainMenuVC.self) {
               navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    //Trigger obj recognition if user has less than full mana
    @objc func manaLongPressed(sender: UILongPressGestureRecognizer) {
        guard selfMana < 5 else {
            //TODO: display "full mana" message
            return
        }
        
        if sender.state == .began {
            playForeground(path: MUTATE_SOUND!)
        }
        
        if sender.state == .ended {
            shouldRecognizeImg = false
        } else {
            shouldRecognizeImg = true
        }
    }
    
    //Decrement user health
    func gotHit() {
        
        selfHealth -= 1
        CurrentGame.selfRef.updateChildValues(["health": selfHealth])
        //RealtimeService.shared.adjustSelfHealth(selfRef: selfRef, health: selfHealth)
    }
    
    //Get position and direction of lightning bolt. Will apply force along the direction from the position
    func determineBoltPosition() -> (SCNVector3, SCNVector3) {
        if let frame = sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let direction = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            let position = SCNVector3(mat.m41, mat.m42, mat.m43)
            
            return (direction, position)
        } else {
            return (SCNVector3(0,0,0), SCNVector3(0,0,0))
        }
    }
    
    
    //MARK: Remove indicators
    @objc func removeHurtIndicator() {
        hurt.removeFromSuperview()
    }
    @objc func removeHitIndicator() {
        hitLanded.removeFromSuperview()
    }
    

}

extension BattleVC: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        //guard shouldRecognizeImg == true else {return}
        //MARK: - Object recognition
        if shouldRecognizeImg == true {
            DispatchQueue.global(qos: .background).async {
                do {
                    let model = try VNCoreMLModel(for: MobileNet().model)
                    let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                        //Main thread
                        DispatchQueue.main.async {
                            guard let results = request.results as? [VNClassificationObservation], let result = results.first else {
                                return
                            }
                            
                            if self.objectArray.contains(result.identifier) {
                                //self.objectArray = self.objectArray.filter{$0 != result.identifier}
                                print("MANA: \(self.selfMana)")
                                if self.selfMana < 5 {
                                    self.selfMana += 1
                                    self.changeBarImage(imageView: self.manaBar, status: self.selfMana, manaOrHealth: "mana")
                                }
                                self.shouldRecognizeImg = false
                                return
                            }
                        }
                    })
                    let capturedImage = frame.capturedImage
                    let handler = VNImageRequestHandler(cvPixelBuffer: capturedImage, options: [:])
                    try handler.perform([request])
                } catch {}
            }
        }
        
        //MARK: - Track user movements
        guard shouldTrackSelf == true else {return}
        
        //Need difference in z position between user z and self ref node z
        let selfZ = sceneView.pointOfView?.position.z
        let selfNodeZ = selfNode.position.z
        let deltaZ = selfZ! - selfNodeZ
        
        //Need difference in x position between user x and self ref node x
        let selfX = sceneView.pointOfView?.position.x
        let selfNodeX = selfNode.position.x
        let deltaX = selfX! - selfNodeX
        
        //Add deltas to database
        let positionData = ["xPosition": deltaX, "zPosition": deltaZ]
        CurrentGame.selfRef.updateChildValues(positionData)
//        selfRef.child("zPosition").setValue(deltaZ)
//        selfRef.child("xPosition").setValue(deltaX)
        
        
    }
}

 // MARK: - ARSCNViewDelegate
extension BattleVC: ARSCNViewDelegate {
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}

//MARK: - PHYSICS
extension BattleVC: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
       // print("yyy \(contact.nodeA.name)\(contact.nodeB.name)")
        if contact.nodeA.name == "opponent" && contact.nodeB.name == "lightning" {
            contact.nodeB.removeFromParentNode()
            DispatchQueue.main.async {
                 //Display hit indicator
                self.sceneView.addSubview(self.hitLanded)
                Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.removeHitIndicator), userInfo: nil, repeats: false)
                //Update opponent health at database
                self.opponentHealth -= 1
                CurrentGame.opponentRef.updateChildValues(["health": self.opponentHealth])
                //RealtimeService.shared.adjustOpponentHealth(opponentRef: self.opponentRef, opponentHealth: self.opponentHealth)
            }
        }
    }
}

extension BattleVC {
    func playBackground(path: String) {
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: path))
        }
        catch {
            print("Error playing audio file: \(error.localizedDescription)")
        }
        backgroundPlayer.play()
        backgroundPlayer.volume = 0.6
        backgroundPlayer.numberOfLoops = 10
    }
    
    
    func playForeground(path: String) {
        do {
            foregroundPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: path))
        }
        catch {
            print("Error playing audio file: \(error.localizedDescription)")
        }
        foregroundPlayer.play()
    }
}
