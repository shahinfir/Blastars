//
//  LabelExtension.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/24/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import Foundation


extension UILabel {
    
    func configureChallengedText(withUsername string: String) {
       
        self.text = "\(string) has challenged you!"
//        var twoBefore: Character!
//        var oneBefore: Character!
//        var current: Character!
//        var username = ""
//        for i in 0..<string.count {
//            guard i > 2 else {continue}
//            twoBefore = string[string.index(string.startIndex, offsetBy: i-2)]
//            oneBefore = string[string.index(string.startIndex, offsetBy: i-1)]
//            current = string[string.index(string.startIndex, offsetBy: i)]
//
//            if "\(twoBefore!)\(oneBefore!)\(current!)" == "has" {
//                for x in 0...(i-4) {
//                    username.append("\(string[string.index(string.startIndex, offsetBy: x)])")
//                    if x == i-4 {
//                        print("Shahin: username is \(username)")
//                        self.text = "\(username) has challenged you!"
//                        return
//                    }
//                }
//            }
//        }
//
//        self.text = "You were challenged!"
    }
    
}

