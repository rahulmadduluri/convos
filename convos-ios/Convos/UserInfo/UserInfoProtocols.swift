//
//  UserInfoProtocols.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

protocol UserInfoVCDelegate {
    func logout()
}

protocol UserInfoComponentDelegate {
    var isMe: Bool { get }
    
    func getUser() -> User?
    func userPhotoEdited(image: UIImage)
    func userNameEdited(name: String)
    func userHandleEdited(handle: String)
    func presentAlertOption(tag: Int)
}

protocol UserInfoUIComponent {
    var userInfoVC: UserInfoComponentDelegate? { get set }
}
