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

protocol Model {
    func toJSON() -> JSON
    init?(json: JSON)
}

// MARK: User Models

class User: NSObject, Model {
    
    // vars
    let uuid: String
    let username: String
    let mobileNumber: String
    let createdServerTimestamp: Int
    let photoURL: String?
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["uuid"],
            let usernameJSON = dictionary["username"],
            let mobileNumberJSON = dictionary["mobileNumber"],
            let createdServerTimestampJSON = dictionary["createdServerTimestamp"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        username = usernameJSON.stringValue
        mobileNumber = mobileNumberJSON.stringValue
        createdServerTimestamp = createdServerTimestampJSON.intValue
        photoURL = dictionary["photoURL"]?.string
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["uuid": JSON(uuid), "username": JSON(username), "mobileNumber": JSON(mobileNumber), "createdServerTimestamp": JSON(createdServerTimestamp)]
        if let photoURL = photoURL {
            dict["photoURL"] = JSON(photoURL)
        }
        return JSON(dict)
    }
    
}

// MARK: Message Models

class Message: NSObject, Model {

    // vars
    let uuid: String
    let senderUUID: String
    let messageText: String?
    let createdServerTimestamp: Int
    let isTopLevel: Bool
    let upvotes: Int
    let children: [Message]

    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["uuid"],
            let senderUUIDJSON = dictionary["senderUUID"],
            let createdServerTimestampJSON = dictionary["createdServerTimestamp"],
            let isTopLevelJSON = dictionary["isTopLevel"],
            let upvotesJSON = dictionary["upvotes"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        senderUUID = senderUUIDJSON.stringValue
        createdServerTimestamp = createdServerTimestampJSON.intValue
        isTopLevel = isTopLevelJSON.boolValue
        upvotes = upvotesJSON.intValue
        messageText = dictionary["messageText"]?.string
        
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
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["uuid": JSON(uuid), "senderUUID": JSON(senderUUID), "createdServerTimestamp": JSON(createdServerTimestamp), "isTopLevel": JSON(isTopLevel)]
        if let text = messageText {
            dict["messageText"] = JSON(text)
        }
        
        var jsonChildren: [JSON] = []
        for child in children {
            jsonChildren.append(child.toJSON())
        }
        dict["children"] = JSON(jsonChildren)
        return JSON(dict)
    }
}

// MARK: Conversation Models

class Conversation: NSObject, Model {
    // vars
    let uuid: String
    let photoURL: String?
    let createdTimestampServer: Int
    let updatedTimestampServer: Int
    let topicTagUUID: String
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["uuid"],
            let createdTimestampServerJSON = dictionary["createdTimestampServer"],
            let updatedTimestampServerJSON = dictionary["updatedTimestampServer"],
            let topicTagUUIDJSON = dictionary["topicTagUUID"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        createdTimestampServer = createdTimestampServerJSON.intValue
        updatedTimestampServer = updatedTimestampServerJSON.intValue
        topicTagUUID = topicTagUUIDJSON.stringValue
        photoURL = dictionary["photoURL"]?.stringValue
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["uuid": JSON(uuid), "createdTimestampServer": JSON(createdTimestampServer), "updatedTimestampServer": JSON(updatedTimestampServer), "topicTagUUID": JSON(topicTagUUID)]
        if let url = photoURL {
            dict["photoURL"] = JSON(url)
        }
        return JSON(dict)
    }
}

// MARK: Tag Model

class Tag: NSObject, Model {
    
    // vars
    let uuid: String
    let name: String
    let isTopic: Bool
    let createdServerTimestamp: Int
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["uuid"],
            let nameJSON = dictionary["name"],
            let isTopicJSON = dictionary["isTopic"],
            let createdServerTimestampJSON = dictionary["createdServerTimestamp"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        name = nameJSON.stringValue
        isTopic = isTopicJSON.boolValue
        createdServerTimestamp = createdServerTimestampJSON.intValue
    }
    
    // Model
    func toJSON() -> JSON {
        let dict: [String: JSON] = ["uuid": JSON(uuid), "name": JSON(name), "isTopic": JSON(isTopic), "createdServerTimestamp": JSON(createdServerTimestamp)]
        return JSON(dict)
    }
    
}
