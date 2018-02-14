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
        let urlString = "http://localhost:8000/users/" + userUUID + "/people"
        return generateSearchForPeopleURL(urlString: urlString, searchText: searchText, maxPeople: maxPeople)
    }
    
    static func getPeopleURL(groupUUID: String, searchText: String?, maxPeople: Int?) -> URL {
        let urlString = "http://localhost:8000/groups/" + groupUUID + "/people"
        return generateSearchForPeopleURL(urlString: urlString, searchText: searchText, maxPeople: maxPeople)
    }
    
    private static func generateSearchForPeopleURL(urlString: String, searchText: String?, maxPeople: Int?) -> URL {
        var mus = urlString
        let searchTextParameter = "searchtext="
        let maxPeopleParameter = "maxpeople="
        if searchText != nil || maxPeople != nil {
            mus += "?"
            if let searchText = searchText, maxPeople == nil {
                mus += searchTextParameter + searchText
            } else if let searchText = searchText, maxPeople != nil {
                mus += searchTextParameter + searchText + "&"
                mus += maxPeopleParameter + String(maxPeople!)
            } else {
                mus += maxPeopleParameter + "maxPeople"
            }
        }
        return URL(string: mus)!
    }
}
