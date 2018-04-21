//
//  SelfNode.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/29/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import Foundation
import ARKit


class SelfNode: SCNNode {
    
    convenience init(sceneView: ARSCNView) {
        let sphere = SCNSphere(radius: 0.1)
        sphere.firstMaterial?.diffuse.contents = UIColor.clear
        self.init(geometry: sphere)
        //Set name
        self.name = "self"
        //Set physics
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape:SCNPhysicsShape(geometry: SCNSphere(radius: 0.5)))
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.mass = 2
        self.physicsBody?.categoryBitMask = 8
        
        //Add to scene
        sceneView.scene.rootNode.addChildNode(self)
        
    }
    
    init(geometry: SCNGeometry) {
        super.init()
        self.geometry = geometry
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
