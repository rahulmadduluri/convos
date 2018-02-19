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
        completion: (@escaping (Bool) -> Void)) {
        let url = REST.updateGroupURL(groupUUID: groupUUID, name: newGroupName, newMemberUUID: newMemberUUID)
        Alamofire.request(
            url,
            method: .put)
            .validate()
            .response { res in
                if res.error == nil {
                    completion(true)
                } else {
                    print("Error while updating group: \(res.error)")
                    completion(false)
                }
        }
    }
    
    static func updateGroupPhoto(
        groupUUID: String,
        photo: UIImage,
        completion: (@escaping (Bool) -> Void)) {
        let url = REST.updateGroupPhotoURL(groupUUID: groupUUID)
        Alamofire.request(
            url,
            method: .put)
            .validate()
            .response { res in
                if res.error == nil {
                    completion(true)
                } else {
                    print("Error while updating group photo: \(res.error)")
                    completion(false)
                }
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
    
    static func createGroup(
        name: String,
        photo: UIImage?,
        memberUUIDs: [String],
        completion: (@escaping (Bool) -> Void)) {
        let url = REST.createGroupURL()
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let photo = photo, let imageData = UIImagePNGRepresentation(photo) {
                multipartFormData.append(imageData, withName: "image.png", mimeType: "image/png")
            }
            multipartFormData.append(name.data(using: .utf8)!, withName: name)
            do {
                let memberUUIDData = try JSON(memberUUIDs).rawData(options: .prettyPrinted)
                multipartFormData.append(memberUUIDData, withName: "memberUUIDs")
            } catch {
                print("Could not create array of member UUIDs")
            }
        }, to: url) { result in
            switch result {
            case .success(_, _, _):
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

}
