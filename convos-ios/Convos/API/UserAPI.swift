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

class GetPeopleResponse: NSObject, APIModel {
    
    // vars
    var people: [User] = []
    let errorMsg: String?
    
    // init
    init(people: [User], errorMsg: String?) {
        self.people = people
        self.errorMsg = errorMsg
    }
    
    required init?(json: JSON) {
        guard let dict = json.dictionary else {
            errorMsg = nil
            return
        }
        if let peopleJSON = dict["People"]?.array {
            for personJSON in peopleJSON {
                if let person = User(json: personJSON) {
                    people.append(person)
                }
            }
        }
        errorMsg = dict["ErrorMsg"]?.string
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = [:]
        var jsonMessages: [JSON] = []
        for person in people {
            jsonMessages.append(person.toJSON())
        }
        dict["People"] = JSON(jsonMessages)
        if let errorMsg = errorMsg {
            dict["ErrorMsg"] = JSON(errorMsg)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return GetPeopleResponse(people: people, errorMsg: errorMsg)
    }
}

class UserAPI: NSObject {
    static func getPeople(
        userUUID: String,
        searchText: String?,
        maxPeople: Int?,
        completion: (@escaping ([User]?) -> Void)) {
        let url = REST.getPeopleURL(userUUID: userUUID, searchText: searchText, maxPeople: maxPeople)
        Alamofire.request(
            url,
            method: .get)
        .validate()
        .responseJSON { response in
            guard response.result.isSuccess else {
                print("Error while fetching people: \(response.result.error)")
                completion(nil)
                return
            }
            
            guard let value = response.result.value as? [String: Any],
                let rows = value["rows"] as? [String: Any] else {
                print("Malformed data received for getPeople")
                completion(nil)
                return
            }
            
            let people = rows.flatMap({ (personJSONData) -> User? in
                return User(json: JSON(personJSONData))
            })
            
            completion(people)
        }
    }
}
