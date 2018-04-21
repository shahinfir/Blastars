//
//  Nodes.swift
//  AR-Cloud-Pong
//
//  Created by Shahin Firouzbakht on 3/13/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import Foundation
import SceneKit

class Nodes {
    
    func healthBar() -> SCNNode {
     let cylinder = SCNCylinder(radius: 0.3, height: 0.9)  // let plane = SCNPlane(width: 1.5, height: 0.3) //let sphere = SCNSphere(radius: 0.3)
        cylinder.firstMaterial?.diffuse.contents = UIColor.red//plane.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/5health.png")//sphere.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/5health.png")
        let node = SCNNode(geometry: cylinder)//let node = SCNNode(geometry: plane)//let node = SCNNode(geometry: sphere)
        node.name = "healthBar"
        node.position = SCNVector3(0, 1, 0)
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape:SCNPhysicsShape(geometry: SCNSphere(radius: 0.1)))
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.mass = 0.1
        //node.physicsBody?.contactTestBitMask = 1
        //node.physicsBody?.collisionBitMask = 1
        node.physicsBody?.categoryBitMask = 4
        return node
    }
    
    func trackingNode() -> SCNNode {
        
        let sphere = SCNSphere(radius: 0.1)
        sphere.firstMaterial?.diffuse.contents = UIColor.clear
        let node = SCNNode(geometry: sphere)
        //Set physics
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape:SCNPhysicsShape(geometry: SCNSphere(radius: 0.5)))
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.mass = 2
        node.physicsBody?.contactTestBitMask = 1
        node.physicsBody?.collisionBitMask = 1
        node.physicsBody?.categoryBitMask = 1
        
        return node
    }
    
    func lightningBolt() -> SCNNode {
        
        let sphere = SCNSphere(radius: 0.2)
        sphere.firstMaterial?.diffuse.contents = UIColor.yellow
        sphere.firstMaterial?.reflective.contents = UIColor.gray
        let node = SCNNode(geometry: sphere)
        node.name = "lightning"
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape:SCNPhysicsShape(geometry: SCNSphere(radius: 0.1)))
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.mass = 0.1
        node.physicsBody?.contactTestBitMask = 1
        // node.physicsBody?.collisionBitMask = 1
        node.physicsBody?.categoryBitMask = 2
        node.position = SCNVector3(0,0,-3)
        node.eulerAngles.z = 90
        node.eulerAngles.x = 45
        return node
    
    }
 
    
}


