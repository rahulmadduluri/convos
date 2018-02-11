//
//  UserAPI.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/11/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class GetPeopleRequest: NSObject, APIModel {
    
    // vars
    let userUUID: String
    let searchText: String
    var numPeople: Int?
    
    // init
    init(userUUID: String, searchText: String, numPeople: Int?) {
        self.userUUID = userUUID
        self.searchText = searchText
        self.numPeople = numPeople
    }
    
    required init?(json: JSON) {
        guard let dict = json.dictionary,
            let userUUIDObject = dict["UserUUID"],
            let searchTextObject = dict["SearchText"] else {
                return nil
        }
        userUUID = userUUIDObject.stringValue
        searchText = searchTextObject.stringValue
        numPeople = dict["NumPeople"]?.int
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict = ["UserUUID": JSON(userUUID), "SearchText": JSON(searchText)]
        if let n = numPeople {
            dict["NumPeople"] = JSON(n)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return GetPeopleRequest(userUUID: userUUID, searchText: searchText, numPeople: numPeople)
    }
}

class UserAPI: NSObject {
    static let _getPeopleRequest = "GetPeopleRequest"
    
    static func getPeople(getPeopleRequest: GetPeopleRequest) {
    }
}
