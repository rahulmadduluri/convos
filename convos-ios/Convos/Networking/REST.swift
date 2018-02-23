//
//  Endpoints.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/4/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class REST: NSObject {
    
    static let baseURL = "http://localhost:8000/"
    
    // Resources
    
    static func imageURL(imageURI: String) -> URL {
        let urlString = baseURL + "static/" + imageURI + ".png"
        return URL(string: urlString)!
    }
    
    static func getPeopleURL(userUUID: String, searchText: String?, maxPeople: Int?) -> URL {
        let urlString = baseURL + "users/" + userUUID + "/people"
        return generateSearchForPeopleURL(urlString: urlString, searchText: searchText, maxPeople: maxPeople)
    }
    
    // Users
    
    private static func generateSearchForPeopleURL(urlString: String, searchText: String?, maxPeople: Int?) -> URL {
        var urlstr = urlString
        let searchTextParameter = "searchtext="
        let maxPeopleParameter = "maxpeople="
        if searchText != nil || maxPeople != nil {
            urlstr += "?"
            if let searchText = searchText, maxPeople == nil {
                urlstr += searchTextParameter + searchText
            } else if let searchText = searchText,
                let maxPeople = maxPeople {
                urlstr += searchTextParameter + searchText + "&"
                urlstr += maxPeopleParameter + String(maxPeople)
            } else if let maxPeople = maxPeople {
                urlstr += maxPeopleParameter + String(maxPeople)
            }
        }
        return URL(string: urlstr)!
    }
    
    // Groups
    
    static func getPeopleURL(groupUUID: String, searchText: String?, maxPeople: Int?) -> URL {
        let urlString = baseURL + "groups/" + groupUUID + "/people"
        return generateSearchForPeopleURL(urlString: urlString, searchText: searchText, maxPeople: maxPeople)
    }
    
    static func updateGroupURL(groupUUID: String, name: String?, newMemberUUID: String?) -> URL {
        let urlString = baseURL + "groups/" + groupUUID
        return generateUpdateGroupMembersURL(urlString: urlString, name: name, newMemberUUID: newMemberUUID)
    }
    
    private static func generateUpdateGroupMembersURL(urlString: String, name: String?, newMemberUUID: String?) -> URL {
        var urlstr = urlString
        let newNameParam = "name="
        let newMemberParam = "memberuuid="
        if name != nil || newMemberUUID != nil {
            urlstr += "?"
            if let name = name, newMemberUUID == nil {
                urlstr += newNameParam + name
            } else if let name = name,
                let newMemberUUID = newMemberUUID {
                urlstr += newNameParam + name + "&"
                urlstr += newMemberParam + newMemberUUID
            } else if let newMemberUUID = newMemberUUID {
                urlstr += newMemberParam + newMemberUUID
            }
        }
        return URL(string: urlstr)!
    }
    
    static func updateGroupPhotoURL(groupUUID: String) -> URL {
        let urlString = baseURL + "groups/" + groupUUID
        return URL(string: urlString)!
    }
    
    static func createGroupURL() -> URL {
        return URL(string: baseURL + "groups")!
    }
    
}
