//
//  UserButtonView.swift
//  blastARs
//
//  Created by Shahin Firouzbakht on 3/30/18.
//  Copyright © 2018 Shahin Firouzbakht. All rights reserved.
//

import UIKit

class UserButtonView: UIView {
    @IBOutlet weak var usernameLbl: UILabel!

    func configure(user: User) {
        usernameLbl.text = user.username
    }

}
