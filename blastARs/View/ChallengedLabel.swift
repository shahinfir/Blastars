//
//  ChallengedLabel.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/24/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit

class ChallengedLabel: UILabel {

    /*
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let string = self.text {
            print("STRING: \(string)")
            getUsernameFrom(string) { username in
                print("USERNAME: \(username)")
                //let myAttribute = [NSAttributedStringKey.shadow: shadow, NSAttributedStringKey.strokeColor : UIColor.white, NSAttributedStringKey.font: UIFont.init(name: "Helvetica", size: 10)]
                let attrs = [NSAttributedStringKey.strokeColor: UIColor.red]
                let attrUsername = NSAttributedString(string: username, attributes: attrs)
                
                self.attributedText = attrUsername
            }
        }
       
       
        
    }
    
    func getUsernameFrom(_ string: String, completion: @escaping(String) -> ()) {
        
        var twoBefore: Character!
        var oneBefore: Character!
        var current: Character!
        var username = ""
        for i in 0..<string.count {
            guard i > 2 else {continue}
            twoBefore = string[string.index(string.startIndex, offsetBy: i-2)]
            oneBefore = string[string.index(string.startIndex, offsetBy: i-1)]
            current = string[string.index(string.startIndex, offsetBy: i)]
            let lastThree = "\(twoBefore)\(oneBefore)\(current)"
            print("Shaihn last three is \(lastThree)")
            
            if "\(twoBefore!)\(oneBefore!)\(current!)" == "has" {
                for x in 0...(i-4) {
                    username.append("\(string[string.index(string.startIndex, offsetBy: x)])")
                    if x == i-4 {
                     //   print("Shahin: username is \(username)")
                        completion(username)
                    }
                }
            }
        }

        completion("You were challenged!")
    } */

}
