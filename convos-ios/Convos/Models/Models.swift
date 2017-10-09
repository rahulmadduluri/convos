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
    
    required init?(json: JSON) {
        
    }
    
    func toJSON() -> JSON {
        return JSON([:])
    }
    
}

// MARK: Message Models

class Message: NSObject, Model {

    // vars
    var uuid: String
    var senderUUID: String
    var messageText: String?
    var createdServerTimestamp: Int
    var isTopLevel: Bool
    var children: [Message]

    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["uuid"],
            let senderUUIDJSON = dictionary["senderUUID"],
            let createdServerTimestampJSON = dictionary["createdServerTimestamp"],
            let isTopLevelJSON = dictionary["isTopLevel"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        senderUUID = senderUUIDJSON.stringValue
        createdServerTimestamp = createdServerTimestampJSON.intValue
        isTopLevel = isTopLevelJSON.boolValue
        children = []
        
        if let receivedChildrenJSON = dictionary["children"]?.arrayValue {
            for child in receivedChildrenJSON {
                guard let newMessage = Message.init(json: child) else {
                    continue
                }
                children.append(newMessage)
            }
        }
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
    var uuid: String
    var photoURL: String?
    var createdTimestampServer: Int
    var updatedTimestampServer: Int
    var topicTagUUID: String
    
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
