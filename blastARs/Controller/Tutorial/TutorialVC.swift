//
//  TutorialVC.swift
//  AR-Cloud-Pong
//
//  Created by Shahin Firouzbakht on 3/14/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import AVFoundation

class TutorialVC: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var reticle: UIImageView!
    @IBOutlet weak var manaImg: UIImageView!
    @IBOutlet weak var healthBar: UIImageView!
    @IBOutlet weak var manaBar: UIImageView!
    @IBOutlet weak var homeImg: UIImageView!
    @IBOutlet weak var shootBtn: UIButton!
    @IBOutlet weak var healBtn: UIButton!
    @IBOutlet weak var reticleImg: UIImageView!
    @IBOutlet weak var messageImg: UIImageView!
    @IBOutlet weak var gotItBtn: UIButton!
    @IBOutlet weak var pointer: UIImageView!
    
    var audioPlayer = AVAudioPlayer()
    
    
    var tutorialCounter = 0
    var selfHealth = 5
    var selfMana = 5
    var opponentHealth = 5
    var objectArray: [String] = ["banana"]
    
    
    var opponentNode: SCNNode!
    var selfNode: SCNNode!
    
    var nodes = Nodes()
    var healthBarNode: SCNNode!
    
    var isEnemyAlive = true //when false, can't tap shoot + display health
    var healAlreadyTapped = false
    
    
    //Bool to determine when didUpdate frame should start sending position data to firebase
    var shouldTrackSelf = false
    var shouldRecognizeImg = false
    var canShoot = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(manaLongPressed))
        manaImg.addGestureRecognizer(longPress)
        
        //Set initial elements as hidden
        manaBar.isHidden = true
        reticleImg.isHidden = true
        shootBtn.isHidden = true
        healBtn.isHidden = true
        manaImg.isHidden = true
        messageImg.image = UIImage(named: "healthMessage")
        pointer.isHidden = true
        pointer.image = UIImage(named: "pointer")
        //display message about hp
        
        
        // Set the scene to the view
        //sceneView.scene = scene
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.scene.rootNode.name = "root"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    @IBAction func gotItTapped(_ sender: Any) {
        playAudio(path: GOT_IT!)
        tutorialCounter += 1
        
        switch tutorialCounter {
        case 1:
            manaBar.isHidden = false
            messageImg.image = UIImage(named: "manaMessage")
        case 2:
            displayDummy()
            reticleImg.isHidden = false
            shootBtn.isHidden = false
            gotItBtn.isHidden = true
            messageImg.image = UIImage(named: "shootMessage")
        case 3:
            manaImg.isHidden = false
            gotItBtn.isHidden = true
            messageImg.image = UIImage(named: "mutateMessage")
        case 4:
            messageImg.image = UIImage(named: "hooray")
        case 5:
            dismiss(animated: true, completion: nil)
        default:
            print("default case")
        }
        
    }
    
    func displayDummy() {
        
        let plane = SCNPlane(width: 1, height: 1)
        plane.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/alien.png")
        let dummyNode = SCNNode(geometry: plane)
        healthBarNode = nodes.healthBar()
        dummyNode.name = "opponent"
//        dummyNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape:SCNPhysicsShape(geometry: SCNSphere(radius: 0.1)))
//        dummyNode.physicsBody?.isAffectedByGravity = false
//        dummyNode.physicsBody?.mass = 0.1
//        dummyNode.physicsBody?.contactTestBitMask = 1
//        dummyNode.physicsBody?.categoryBitMask = 2
        let userPovSimd = sceneView.pointOfView?.simdTransform
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -6
        dummyNode.simdTransform = matrix_multiply(userPovSimd!, translation)
        dummyNode.addChildNode(healthBarNode)
        sceneView.scene.rootNode.addChildNode(dummyNode)
        
        
        
    }
    
    func createSelfAndOpponentNodes() {
    
        //Create opponent reference node and opponent health node
        opponentNode = nodes.trackingNode()
        opponentNode.name = "opponent"
        let opponentHealthNode = nodes.healthBar()
        
        //Place opponent in scene view, immediately in front of player 1 (current user)
        let userPovSimd = sceneView.pointOfView?.simdTransform
        opponentNode.simdTransform = userPovSimd!
        let worldOrientationY = sceneView.scene.rootNode.worldOrientation.y
        opponentNode.worldOrientation.y = worldOrientationY
        sceneView.scene.rootNode.eulerAngles.y = (sceneView.pointOfView?.eulerAngles.y)!
        sceneView.scene.rootNode.addChildNode(opponentNode)
        
        //Place opponent health bar above tracking node, as child of tracking node
        opponentNode.addChildNode(opponentHealthNode)
        
        //Add self reference node
        selfNode = nodes.trackingNode()
        selfNode.name = "self"
        selfNode.physicsBody?.categoryBitMask = 8
        //Add self reference node to scene view
        sceneView.scene.rootNode.addChildNode(selfNode)
        shouldTrackSelf = true
        
      
        
    }
    
   
    func changeBarImage(imageView: UIImageView, status: Int, manaOrHealth: String) {
        imageView.image = UIImage(named: "\(status)\(manaOrHealth)")
    }
    
    func getShotAt() {
        
        let lightningNode = nodes.lightningBolt()
        let sphere = SCNSphere(radius: 0.2)
        sphere.firstMaterial?.diffuse.contents = UIColor.red
        
        let animation = CABasicAnimation(keyPath: #keyPath(SCNNode.position))
        animation.fromValue = opponentNode.position
        animation.toValue = sceneView.pointOfView!.position
        animation.duration = 3
        animation.autoreverses = false
        animation.repeatCount = 0
        sceneView.scene.rootNode.addChildNode(lightningNode)
        lightningNode.addAnimation(animation, forKey: nil)
        
        
        //Increment a counter
        //Set timer
        //Selector
        
        
    }
    
    
    

    
    @IBAction func shootTapped(_ sender: Any) {
        guard canShoot == true else {
            return
        }
        playAudio(path: LIGHTNING_BOLT!)
        canShoot = false
        
        selfMana -= 1
        changeBarImage(imageView: manaBar, status: selfMana, manaOrHealth: "mana")
        
        //Decrement health
        changeBarImage(imageView: healthBar, status: 4, manaOrHealth: "health")
        
        let lightningNode = nodes.lightningBolt()
        lightningNode.name = "lightning"
        let positionData = determineBoltPosition()
        lightningNode.position = positionData.1
        let direction = positionData.0
        lightningNode.physicsBody?.applyForce(direction, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(lightningNode)
        
        messageImg.image = UIImage(named: "healMessage")
        healBtn.isHidden = false
        
        healthBarNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/0health.png")
        
    }
    
    @IBAction func healTapped(_ sender: Any) {
        guard healAlreadyTapped == false else {return}
        
        playAudio(path: HEALTH_REGEN!)
        
        manaBar.image = UIImage(named: "3mana")
        healthBar.image = UIImage(named: "5health")
        healAlreadyTapped = true
        gotItBtn.isHidden = false
        messageImg.image = UIImage(named: "lowEnergyMessage")

    }
    
    @IBAction func homeTapped(_ sender: Any) {
        for vc in navigationController!.viewControllers {
            if vc.isKind(of: MainMenuVC.self) {
                navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    
    @objc func manaLongPressed(sender: UILongPressGestureRecognizer) {
        guard selfMana < 5 else {
            //TODO: change message to `items that can be displayed`
            return
        }
        
        //Play audio, only once
        if sender.state == .began {
            playAudio(path: MUTATE_SOUND!)
        }
        
        if sender.state == .ended {
            shouldRecognizeImg = false
        } else {
            shouldRecognizeImg = true
        }
    }
    
    
    func gotHit() {
        selfHealth -= 1
    }
    
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
    
    func okAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension TutorialVC: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        //guard shouldRecognizeImg == true else {return}
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
                                    self.messageImg.image = UIImage(named: "itemsListMessage")
                                    self.gotItBtn.isHidden = false
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
        
        
    }
}

// MARK: - ARSCNViewDelegate
extension TutorialVC: ARSCNViewDelegate {
    
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

extension TutorialVC: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("yyy: did begin")
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
         print("yyy \(contact.nodeA.name)\(contact.nodeB.name)")
        if contact.nodeA.name == "opponent" && contact.nodeB.name == "lightning" {
            contact.nodeB.removeFromParentNode()
            contact.nodeA.childNode(withName: "healthBar", recursively: true)?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/0health.png")
            messageImg.image = UIImage(named: "healMessage")
            healBtn.isHidden = false
            
        }
    }
}

extension TutorialVC {
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

