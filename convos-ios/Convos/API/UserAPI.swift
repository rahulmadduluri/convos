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
    static func getContacts(
        userUUID: String,
        searchText: String?,
        maxContacts: Int?,
        completion: (@escaping ([User]?) -> Void)) {
        let url = REST.getContactsURL(userUUID: userUUID, searchText: searchText, maxContacts: maxContacts)
        Alamofire.request(
            url,
            method: .get)
        .validate()
        .responseJSON { response in
            completion(convertResponseToContacts(res: response))
        }
    }
    
    static func getPeople(
        searchText: String?,
        maxUsers: Int?,
        completion: (@escaping ([User]?) -> Void)) {
        let url = REST.getPeopleURL(searchText: searchText, maxUsers: maxUsers)
        Alamofire.request(
            url,
            method: .get)
            .validate()
            .responseJSON { response in
                completion(convertResponseToContacts(res: response))
        }
    }
    
    static func addContact(userUUID: String, contactUUID: String, completion: (@escaping (Bool) -> Void)) {
        let url = REST.addContactURL(userUUID: userUUID)
        let params: [String: Any] = ["contactuuid": contactUUID]
        Alamofire.request(
            url,
            method: .post,
            parameters: params)
            .validate()
            .response { res in
                if res.error == nil {
                    completion(true)
                } else {
                    print("Error while updating conversation photo: \(res.error)")
                    completion(false)
                }
        }
    }
    
    static func updateUser(
        userUUID: String,
        name: String?,
        handle: String?,
        completion: (@escaping (Bool) -> Void)) {
        let url = REST.updateUserNameURL(userUUID: userUUID)
        var params: [String: Any] = [:]
        if let name = name {
            params["name"] = name
        }
        if let handle = handle {
            params["handle"] = handle
        }
        Alamofire.request(
            url,
            method: .put,
            parameters: params)
            .validate()
            .response { res in
                if res.error == nil {
                    completion(true)
                } else {
                    print("Error while updating user: \(res.error)")
                    completion(false)
                }
        }
    }
    
    static func updateUserPhoto(
        userUUID: String,
        photo: UIImage,
        completion: (@escaping (Bool) -> Void)) {
        let url = REST.updateUserPhotoURL(userUUID: userUUID)
        Alamofire.request(
            url,
            method: .put)
            .validate()
            .response { res in
                if res.error == nil {
                    completion(true)
                } else {
                    print("Error while updating user photo: \(res.error)")
                    completion(false)
                }
        }
    }
    
    static func createUser(
        name: String,
        handle: String,
        photo: UIImage?,
        completion: (@escaping (Bool) -> Void)) {
        let url = REST.createUserURL()
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let photo = photo, let imageData = UIImagePNGRepresentation(photo) {
                multipartFormData.append(imageData, withName: "image.png", mimeType: "image/png")
            }
            multipartFormData.append(name.data(using: .utf8)!, withName: "name")
            multipartFormData.append(handle.data(using: .utf8)!, withName: "handle")
        }, to: url) { result in
            switch result {
            case .success(_, _, _):
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    private static func convertResponseToContacts(res: Alamofire.DataResponse<Any>) -> [User]? {
        guard res.result.isSuccess else {
            print("Error while fetching people: \(res.result.error)")
            return nil
        }
        
        if res.data != nil {
            let jsonArray = JSON(data: res.data!)
            var contacts: [User] = []
            for (_, c) in jsonArray {
                if let u = User(json: c) {
                    contacts.append(u)
                }
            }
            return contacts
        }
        return nil
    }

}
