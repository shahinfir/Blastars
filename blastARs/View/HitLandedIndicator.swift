//
//  HitLandedIndicator.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/30/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit

class HitLandedIndicator: UIImageView {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.image = UIImage(named: "hitLanded")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
