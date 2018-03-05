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
    
    private static func convertResponseToContacts(res: Alamofire.DataResponse<Any>) -> [User]? {
        guard res.result.isSuccess else {
            print("Error while fetching contacts: \(res.result.error)")
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
