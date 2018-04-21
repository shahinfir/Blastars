//
//  CustomTextField.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/31/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let string = placeholder {
            let attrs = [NSAttributedStringKey.foregroundColor:UIColor.white]
            let attrsString = NSAttributedString(string: string, attributes: attrs)
            attributedPlaceholder = attrsString
        }
        
    }
}
