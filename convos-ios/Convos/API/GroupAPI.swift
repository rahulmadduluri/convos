//
//  GroupAPI.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/17/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class GroupAPI: NSObject {
    static func updateGroup(
        groupUUID: String,
        newGroupName: String?,
        newMemberUUID: String?,
        completion: (@escaping (Group?) -> Void)) {
        let url = REST.updateGroupURL(groupUUID: groupUUID, name: newGroupName, newMemberUUID: newMemberUUID)
        Alamofire.request(
            url,
            method: .put)
            .validate()
            .responseJSON { response in
                completion(convertResponseToGroup(res: response))
        }
    }
    
    static func updateGroupPhoto(
        groupUUID: String,
        photo: UIImage,
        completion: (@escaping (Group?) -> Void)) {
        let url = REST.updateGroupPhotoURL(groupUUID: groupUUID)
        Alamofire.request(
            url,
            method: .put)
            .validate()
            .responseJSON { response in
                completion(convertResponseToGroup(res: response))
        }
    }
    
    static func getPeople(
        groupUUID: String,
        searchText: String?,
        maxPeople: Int?,
        completion: (@escaping ([User]?) -> Void)) {
        let url = REST.getPeopleURL(groupUUID: groupUUID, searchText: searchText, maxPeople: maxPeople)
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
    
    private static func convertResponseToGroup(res: Alamofire.DataResponse<Any>) -> Group? {
        guard res.result.isSuccess else {
            print("Error while fetching people: \(res.result.error)")
            return nil
        }
        
        if let d = res.data,
            let group = Group(json: JSON(d)) {
            return group
        }
        return nil
    }
    
}
