//
//  Headers.swift
//  Convos
//
//  Created by Rahul Madduluri on 4/7/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith

class Headers: NSObject {
    
    static private var headers = Alamofire.HTTPHeaders()
    
    static func defaultHeaders() -> Alamofire.HTTPHeaders {
        return headers
    }
    
    static func setAccessToken() {
        if let dictionary = Locksmith.loadDataForUserAccount(userAccount: "user_account"),
            let atRaw = dictionary["access_token"],
            let accessToken = atRaw as? String {
            headers["Authorization: Bearer"] = accessToken
        }
    }
}
