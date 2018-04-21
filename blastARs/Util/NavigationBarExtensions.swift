//
//  NavigationBarExtensions.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/21/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit

extension UINavigationController: UINavigationBarDelegate {
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPush item: UINavigationItem) -> Bool {
      
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear
        navigationBar.backIndicatorImage = UIImage(named: "back")
        
        
        //Remove "Back" from back bar button
        let backItem = UIBarButtonItem(title: " ", style: .plain, target: self, action: nil)
        backItem.tintColor = UIColor.yellow
        
        navigationBar.topItem?.backBarButtonItem = backItem

        //Set back indicator arrow
        let backImg = UIImage(named: "back")
        navigationBar.backIndicatorImage = backImg
        navigationBar.backIndicatorTransitionMaskImage = backImg
        
        //Set title text for screens that have nav bar titles
        //        //WHICH SHOULD BE SET IN INTERFACE BUILDER
        //        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        //        titleTextAttributes = textAttributes
        
        return true
    }
    
    func setBarTranslucent() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear
    }
    
}
