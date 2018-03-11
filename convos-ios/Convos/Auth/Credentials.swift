//
//  Credentials.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/11/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import Auth0

class Credentials: NSObject {
    static let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
}
