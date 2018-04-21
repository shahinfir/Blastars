//
//  HealthBarNode.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/29/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import Foundation
import ARKit

class HealthBarNode: SCNNode {
    
    override init() {
        super.init()
    
        let cylinder = SCNCylinder(radius: 0.3, height: 0.9)
        cylinder.firstMaterial?.diffuse.contents = UIColor.red
        self.geometry = cylinder
        //Set name
        self.name = "healthBar"
        //Set position
        self.position = SCNVector3(0, 1, 0)
        //Set physics
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape:SCNPhysicsShape(geometry: SCNSphere(radius: 0.1)))
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.mass = 0.1
        self.physicsBody?.categoryBitMask = 4
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
