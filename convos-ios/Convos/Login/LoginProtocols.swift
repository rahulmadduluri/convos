//
//  LoginProtocols.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/11/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

protocol LoginVCDelegate {
    func loggedIn()
}

protocol LoginUIComponentDelegate {
    func loginTapped()
}
