//
//  Models.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/26/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON

// MARK: Model Protocols

protocol Model {}

protocol APIModel {
    func toJSON() -> JSON
    init?(json: JSON)
}

// MARK: User Models

class User: NSObject, APIModel {
    
    // vars
    let uuid: String
    let username: String
    let mobileNumber: String
    let photoURL: String?
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["uuid"],
            let usernameJSON = dictionary["username"],
            let mobileNumberJSON = dictionary["mobileNumber"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        username = usernameJSON.stringValue
        mobileNumber = mobileNumberJSON.stringValue
        photoURL = dictionary["photoURL"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["uuid": JSON(uuid), "username": JSON(username), "mobileNumber": JSON(mobileNumber)]
        if let photoURL = photoURL {
            dict["photoURL"] = JSON(photoURL)
        }
        return JSON(dict)
    }
    
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.uuid == rhs.uuid
}

// MARK: Message Models

class Message: NSObject, APIModel {

    // vars
    let uuid: String
    let senderUUID: String
    let fullText: String?
    let createdTimestampServer: Int
    let isTopLevel: Bool
    let children: [Message]

    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["uuid"],
            let senderUUIDJSON = dictionary["senderUUID"],
            let createdTimestampServerJSON = dictionary["createdTimestampServer"],
            let isTopLevelJSON = dictionary["isTopLevel"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        senderUUID = senderUUIDJSON.stringValue
        createdTimestampServer = createdTimestampServerJSON.intValue
        isTopLevel = isTopLevelJSON.boolValue
        fullText = dictionary["fullText"]?.string
        
        var tempChildren: [Message] = []
        
        if let receivedChildrenJSON = dictionary["children"]?.arrayValue {
            for child in receivedChildrenJSON {
                guard let newMessage = Message.init(json: child) else {
                    continue
                }
                tempChildren.append(newMessage)
            }
        }
        children = tempChildren
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["uuid": JSON(uuid), "senderUUID": JSON(senderUUID), "createdTimestampServer": JSON(createdTimestampServer), "isTopLevel": JSON(isTopLevel)]
        if let text = fullText {
            dict["fullText"] = JSON(text)
        }
        
        var jsonChildren: [JSON] = []
        for child in children {
            jsonChildren.append(child.toJSON())
        }
        dict["children"] = JSON(jsonChildren)
        return JSON(dict)
    }
}

func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.uuid == rhs.uuid
}

// MARK: Conversation Models

class Conversation: NSObject, APIModel {
    // vars
    let uuid: String
    let groupUUID: String
    let createdTimestampServer: Int
    let updatedTimestampServer: Int
    let topicTagUUID: String
    let title: String
    let isDefault: Bool
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["uuid"],
            let groupUUIDJSON = dictionary["groupUUID"],
            let createdTimestampServerJSON = dictionary["createdTimestampServer"],
            let updatedTimestampServerJSON = dictionary["updatedTimestampServer"],
            let topicTagUUIDJSON = dictionary["topicTagUUID"],
            let titleJSON = dictionary["title"],
            let isDefaultJSON = dictionary["isDefault"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        groupUUID = groupUUIDJSON.stringValue
        createdTimestampServer = createdTimestampServerJSON.intValue
        updatedTimestampServer = updatedTimestampServerJSON.intValue
        topicTagUUID = topicTagUUIDJSON.stringValue
        title = titleJSON.stringValue
        isDefault = isDefaultJSON.boolValue
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["uuid": JSON(uuid), "groupUUID": JSON(groupUUID), "createdTimestampServer": JSON(createdTimestampServer), "updatedTimestampServer": JSON(updatedTimestampServer), "topicTagUUID": JSON(topicTagUUID), "title": JSON(title), "isDefault": JSON(isDefault)]
        return JSON(dict)
    }
}

func ==(lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.uuid == rhs.uuid
}

// MARK: Tag Model

class Tag: NSObject, APIModel {
    
    // vars
    let uuid: String
    let name: String
    let isTopic: Bool
    let createdTimestampServer: Int
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["uuid"],
            let nameJSON = dictionary["name"],
            let isTopicJSON = dictionary["isTopic"],
            let createdTimestampServerJSON = dictionary["createdTimestampServer"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        name = nameJSON.stringValue
        isTopic = isTopicJSON.boolValue
        createdTimestampServer = createdTimestampServerJSON.intValue
    }
    
    // Model
    func toJSON() -> JSON {
        let dict: [String: JSON] = ["uuid": JSON(uuid), "name": JSON(name), "isTopic": JSON(isTopic), "createdTimestampServer": JSON(createdTimestampServer)]
        return JSON(dict)
    }
    
}

func ==(lhs: Tag, rhs: Tag) -> Bool {
    return lhs.uuid == rhs.uuid
}

// MARK: Group Model

class Group: NSObject, APIModel {
    
    // vars
    let uuid: String
    let name: String
    let photoURL: String?
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["uuid"],
            let nameJSON = dictionary["name"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        name = nameJSON.stringValue
        photoURL = dictionary["photoURL"]?.string
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["uuid": JSON(uuid), "name": JSON(name)]
        if let url = photoURL {
            dict["photoURL"] = JSON(url)
        }
        return JSON(dict)
    }
    
}

func ==(lhs: Group, rhs: Group) -> Bool {
    return lhs.uuid == rhs.uuid
}
