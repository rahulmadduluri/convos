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
            completion(convertResponseToPeople(res: response))
        }
    }
    
    private static func convertResponseToPeople(res: Alamofire.DataResponse<Any>) -> [User]? {
        guard res.result.isSuccess else {
            print("Error while fetching people: \(res.result.error)")
            return nil
        }
        
        if res.data != nil {
            let jsonArray = JSON(data: res.data!)
            var people: [User] = []
            for (_, p) in jsonArray {
                if let u = User(json: p) {
                    people.append(u)
                }
            }
            return people
        }
        return nil
    }

}
