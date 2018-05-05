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
        var params: [String: Any] = [:]
        if let name = newGroupName {
            params[Constants.nameParam] = name
        }
        if let newMemberUUID = newMemberUUID {
            params[Constants.memberUUIDParam] = newMemberUUID
        }
        Alamofire.request(
            url,
            method: .put,
            parameters: params,
            headers: APIHeaders.defaultHeaders())
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
            method: .put,
            headers: APIHeaders.defaultHeaders())
            .validate()
            .response { res in
                if res.error == nil {
                    completion(true)
                } else {
                    print("Error while updating group photo: \(res.error)")
                    if res.response?.statusCode != 200 {
                        APIHeaders.resetAccessToken{ _ in
                            completion(false)
                        }
                    }
                }
        }
    }
    
    static func getConversations(
        groupUUID: String,
        maxConversations: Int?,
        completion: (@escaping ([Conversation]?) -> Void)) {
        let url = REST.getConversationsURL(groupUUID: groupUUID, maxConversations: maxConversations)
        Alamofire.request(
            url,
            method: .get,
            headers: APIHeaders.defaultHeaders())
            .validate()
            .responseJSON { res in
                if res.error == nil {
                    completion(convertResponseToConversations(res: res))
                } else {
                    print("Error while updating group photo: \(res.error)")
                    if res.response?.statusCode != 200 {
                        APIHeaders.resetAccessToken{ _ in
                            completion(nil)
                        }
                    }
                }
        }
    }
    
    private static func convertResponseToConversations(res: Alamofire.DataResponse<Any>) -> [Conversation]? {
        guard res.result.isSuccess else {
            print("Error while fetching conversations: \(res.result.error)")
            return nil
        }
        
        if res.data != nil {
            let jsonArray = JSON(data: res.data!)
            var conversations: [Conversation] = []
            for (_, cRaw) in jsonArray {
                if let c = Conversation(json: cRaw) {
                    conversations.append(c)
                }
            }
            return conversations
        }
        return nil
    }
    
    static func getMembers(
        groupUUID: String,
        searchText: String?,
        maxMembers: Int?,
        completion: (@escaping ([User]?) -> Void)) {
        let url = REST.getMembersURL(groupUUID: groupUUID, searchText: searchText, maxMembers: maxMembers)
        Alamofire.request(
            url,
            method: .get,
            headers: APIHeaders.defaultHeaders())
            .validate()
            .responseJSON { res in
                if res.error == nil {
                    completion(convertResponseToMembers(res: res))
                } else {
                    print("Error while updating group photo: \(res.error)")
                    if res.response?.statusCode != 200 {
                        APIHeaders.resetAccessToken{ _ in
                            completion(nil)
                        }
                    }
                }
        }
    }
    
    private static func convertResponseToMembers(res: Alamofire.DataResponse<Any>) -> [User]? {
        guard res.result.isSuccess else {
            print("Error while fetching members: \(res.result.error)")
            return nil
        }
        
        if res.data != nil {
            let jsonArray = JSON(data: res.data!)
            var members: [User] = []
            for (_, m) in jsonArray {
                if let u = User(json: m) {
                    members.append(u)
                }
            }
            return members
        }
        return nil
    }
    
    static func createGroup(
        name: String,
        handle: String,
        photo: UIImage?,
        memberUUIDs: [String],
        completion: (@escaping (Bool) -> Void)) {
        let url = REST.createGroupURL()
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let photo = photo, let imageData = UIImagePNGRepresentation(photo) {
                multipartFormData.append(imageData, withName: "image.png", mimeType: "image/png")
            }
            multipartFormData.append(name.data(using: .utf8)!, withName: Constants.nameParam)
            multipartFormData.append(handle.data(using: .utf8)!, withName: Constants.handleParam)
            do {
                let memberUUIDData = try JSON(memberUUIDs).rawData(options: .prettyPrinted)
                multipartFormData.append(memberUUIDData, withName: Constants.memberUUIDsParam)
            } catch {
                print("Could not create array of member UUIDs")
            }
        }, to: url,
           headers: APIHeaders.defaultHeaders()) { res in
            switch res {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    if response.result.value != nil{
                        DispatchQueue.main.async {
                            if(response.response?.statusCode != 200){
                                completion(true)
                            } else{
                                completion(false)
                            }
                        }
                    } else {
                        completion(false)
                    }
                }
            case .failure:
                print("Failed to create a group")
                APIHeaders.resetAccessToken{ _ in
                    completion(false)
                }
            }
        }
    }

}

private struct Constants {
    static let nameParam = "name"
    static let handleParam = "handle"
    static let memberUUIDParam = "memberuuid"
    static let memberUUIDsParam = "memberuuids"
}
