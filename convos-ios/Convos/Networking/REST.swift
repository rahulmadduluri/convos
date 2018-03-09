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
    
    static func validateString(rawString: String) -> String {
        return rawString.replacingOccurrences(of: " ", with: "")
    }
    
    // Resources
    
    static func imageURL(imageURI: String) -> URL {
        let urlString = baseURL + "static/" + imageURI + ".png"
        let validatedURL = validateString(rawString: urlString)
        return URL(string: validatedURL)!
    }
    
    // Users
    
    static func getContactsURL(userUUID: String, searchText: String?, maxContacts: Int?) -> URL {
        let urlString = baseURL + "users/" + userUUID + "/contacts"
        return generateSearchForContactsURL(urlString: urlString, searchText: searchText, maxContacts: maxContacts)
    }
    
    static func getPeopleURL(searchText: String?, maxUsers: Int?) -> URL {
        let urlString = baseURL + "users"
        return generateSearchForPeopleURL(urlString: urlString, searchText: searchText, maxUsers: maxUsers)
    }
    
    private static func generateSearchForContactsURL(urlString: String, searchText: String?, maxContacts: Int?) -> URL {
        var urlstr = urlString
        let searchTextParameter = "searchtext="
        let maxContactsParameter = "maxcontacts="
        if searchText != nil || maxContacts != nil {
            urlstr += "?"
            if let searchText = searchText, maxContacts == nil {
                urlstr += searchTextParameter + searchText
            } else if let searchText = searchText,
                let maxContacts = maxContacts {
                urlstr += searchTextParameter + searchText + "&"
                urlstr += maxContactsParameter + String(maxContacts)
            } else if let maxContacts = maxContacts {
                urlstr += maxContactsParameter + String(maxContacts)
            }
        }
        let validatedURL = validateString(rawString: urlstr)
        return URL(string: validatedURL)!
    }
    
    
    private static func generateSearchForPeopleURL(urlString: String, searchText: String?, maxUsers: Int?) -> URL {
        var urlstr = urlString
        let searchTextParameter = "searchtext="
        let maxUsersParameter = "maxusers="
        if searchText != nil || maxUsers != nil {
            urlstr += "?"
            if let searchText = searchText, maxUsers == nil {
                urlstr += searchTextParameter + searchText
            } else if let searchText = searchText,
                let maxUsers = maxUsers {
                urlstr += searchTextParameter + searchText + "&"
                urlstr += maxUsersParameter + String(maxUsers)
            } else if let maxUsers = maxUsers {
                urlstr += maxUsersParameter + String(maxUsers)
            }
        }
        let validatedURL = validateString(rawString: urlstr)
        return URL(string: validatedURL)!
    }
    
    // Groups
    
    static func getMembersURL(groupUUID: String, searchText: String?, maxMembers: Int?) -> URL {
        let urlString = baseURL + "groups/" + groupUUID + "/members"
        return generateSearchForMembersURL(urlString: urlString, searchText: searchText, maxMembers: maxMembers)
    }
    
    private static func generateSearchForMembersURL(urlString: String, searchText: String?, maxMembers: Int?) -> URL {
        var urlstr = urlString
        let searchTextParameter = "searchtext="
        let maxMembersParameter = "maxmembers="
        if searchText != nil || maxMembers != nil {
            urlstr += "?"
            if let searchText = searchText, maxMembers == nil {
                urlstr += searchTextParameter + searchText
            } else if let searchText = searchText,
                let maxMembers = maxMembers {
                urlstr += searchTextParameter + searchText + "&"
                urlstr += maxMembersParameter + String(maxMembers)
            } else if let maxMembers = maxMembers {
                urlstr += maxMembersParameter + String(maxMembers)
            }
        }
        let validatedURL = validateString(rawString: urlstr)
        return URL(string: validatedURL)!
    }
    
    static func updateGroupURL(groupUUID: String, name: String?, newMemberUUID: String?) -> URL {
        let urlString = baseURL + "groups/" + groupUUID
        return generateUpdateGroupURL(urlString: urlString, name: name, newMemberUUID: newMemberUUID)
    }
    
    private static func generateUpdateGroupURL(urlString: String, name: String?, newMemberUUID: String?) -> URL {
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
        let validatedURL = validateString(rawString: urlstr)
        return URL(string: validatedURL)!
    }
    
    static func updateGroupPhotoURL(groupUUID: String) -> URL {
        let urlString = baseURL + "groups/" + groupUUID
        return URL(string: urlString)!
    }
    
    static func createGroupURL() -> URL {
        return URL(string: baseURL + "groups")!
    }
    
    // Conversation
    
    static func updateConversationURL(conversationUUID: String, topic: String?, newTagUUID: String?) -> URL {
        let urlString = baseURL + "conversations/" + conversationUUID
        return generateUpdateConversationURL(urlString: urlString, topic: topic, newTagUUID: newTagUUID)
    }
    
    private static func generateUpdateConversationURL(urlString: String, topic: String?, newTagUUID: String?) -> URL {
        var urlstr = urlString
        let newTopicParam = "topic="
        let newTagParam = "taguuid="
        if topic != nil || newTagUUID != nil {
            urlstr += "?"
            if let topic = topic, newTagUUID == nil {
                urlstr += newTagParam + topic
            } else if let topic = topic,
                let newTagUUID = newTagUUID {
                urlstr += newTopicParam + topic + "&"
                urlstr += newTagUUID + newTagUUID
            } else if let newTagUUID = newTagUUID {
                urlstr += newTagUUID + newTagUUID
            }
        }
        let validatedURL = validateString(rawString: urlstr)
        return URL(string: validatedURL)!
    }
    
    static func updateConversationPhotoURL(conversationUUID: String) -> URL {
        let urlString = baseURL + "conversations/" + conversationUUID
        return URL(string: urlString)!
    }
    
    static func createConversationURL() -> URL {
        return URL(string: baseURL + "conversations")!
    }
    
}
