//
//  AnimationService.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/21/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit

class AnimationService {
    private init() {}
    static let shared = AnimationService()
    
    func shiftViewDown(vc: UIViewController) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            vc.view.frame.origin.y = 0
            vc.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func rotate(image: UIImageView) {
        print("calling rotate")

        UIView.animate(withDuration: 0.75, animations: {
            image.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            image.transform = CGAffineTransform(rotationAngle: 2*CGFloat.pi)
        })
        { (ok) in
            self.rotate(image: image)
        }
    }
    
}
