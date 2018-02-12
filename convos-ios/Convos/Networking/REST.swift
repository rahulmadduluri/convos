//
//  Endpoints.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/4/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class REST: NSObject {
    static func imageURL(imageURI: String) -> URL {
        let urlString = "http://localhost:8000/static/" + imageURI + ".png"
        return URL(string: urlString)!
    }
    
    static func getPeopleURL(userUUID: String, searchText: String?, maxPeople: Int?) -> URL {
        var urlString = "http://localhost:8000/user/" + userUUID + "/people"
        let searchTextParameter = "searchText="
        let maxPeopleParameter = "maxPeople="
        if searchText != nil || maxPeople != nil {
            urlString = urlString + "?"
            if let searchText = searchText, maxPeople == nil {
                urlString = urlString + searchTextParameter + searchText
            } else if let searchText = searchText, maxPeople != nil {
                urlString = urlString + searchTextParameter + searchText + "&" + maxPeopleParameter + "maxPeople"
            } else {
                urlString = urlString + maxPeopleParameter + "maxPeople"
            }
        }
        return URL(string: urlString)!
    }
}
