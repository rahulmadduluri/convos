//
//  Endpoints.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/4/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class REST: NSObject {
    static func generateImageURL(imageURI: String) -> URL {
        let urlString = "http://localhost:8000/static/" + imageURI + ".png"
        return URL(string: urlString)!
    }
}
