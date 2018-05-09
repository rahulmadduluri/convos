//
//  Headers.swift
//  Convos
//
//  Created by Rahul Madduluri on 4/7/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import Alamofire

class APIHeaders: NSObject {
    
    static private var headers = Alamofire.HTTPHeaders()
    
    static func defaultHeaders() -> Alamofire.HTTPHeaders {
        return headers
    }
    
    static func reset() {
        headers = Alamofire.HTTPHeaders()
    }
    
    static func authorizationValue() -> String {
        return headers["Authorization"] ?? ""
    }
    
    static func hasAccessToken() -> Bool {
        return headers["Authorization"] != nil
    }
    
    static func setAccessToken(accessToken: String) {
        headers["Authorization"] = "Bearer " + accessToken
    }
    
    static func setUUID(uuid: String) {
        headers["x-uuid"] = uuid
    }
    
    static func resetAccessToken(completion: (@escaping (Bool) -> Void)) {
        MyAuth.fetchAccessToken { accessToken in
            if let t = accessToken {
                APIHeaders.setAccessToken(accessToken: t)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
