//
//  NewUserProtocols.swift
//  Convos
//
//  Created by Rahul Madduluri on 4/15/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

protocol NewUserVCDelegate {
    func userCreated(uuid: String, mobileNumber: String, name: String, handle: String, photoURI: String?)
}

protocol NewUserUIComponentDelegate {
    func createUserTapped()
}

protocol NewUserUIComponent {
    var newUserVC: NewUserVCDelegate? { get set }
}
