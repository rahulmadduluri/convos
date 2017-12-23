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

protocol APIModel: Model {
    func toJSON() -> JSON
    init?(json: JSON)
}

// MARK: User Models

class User: NSObject, APIModel {
    
    // vars
    let uuid: String
    let username: String
    let photoURL: String?
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["UUID"],
            let usernameJSON = dictionary["Username"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        username = usernameJSON.stringValue
        photoURL = dictionary["PhotoURL"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["UUID": JSON(uuid), "Username": JSON(username)]
        if let photoURL = photoURL {
            dict["PhotoURL"] = JSON(photoURL)
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
    let fullText: String
    let createdTimestampServer: Int
    let isTopLevel: Bool
    let parentUUID: String?

    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["UUID"],
            let senderUUIDJSON = dictionary["SenderUUID"],
            let fullTextJSON = dictionary["FullText"],
            let createdTimestampServerJSON = dictionary["CreatedTimestampServer"],
            let isTopLevelJSON = dictionary["IsTopLevel"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        senderUUID = senderUUIDJSON.stringValue
        fullText = fullTextJSON.stringValue
        createdTimestampServer = createdTimestampServerJSON.intValue
        isTopLevel = isTopLevelJSON.boolValue
        parentUUID = dictionary["ParentUUID"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["UUID": JSON(uuid), "SenderUUID": JSON(senderUUID), "FullText": JSON(fullText), "CreatedTimestampServer": JSON(createdTimestampServer), "IsTopLevel": JSON(isTopLevel)]
        if let parentUUID = parentUUID {
            dict["ParentUUID"] = JSON(parentUUID)
        }
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
    let updatedTimestampServer: Int
    let topicTagUUID: String
    let topic: String
    let isDefault: Bool
    let groupPhotoURL: String?
    
    // init
    init(uuid: String, groupUUID: String, updatedTimestampServer: Int, topicTagUUID: String, topic: String, isDefault: Bool, groupPhotoURL: String? = nil) {
        self.uuid = uuid
        self.groupUUID = groupUUID
        self.updatedTimestampServer = updatedTimestampServer
        self.topicTagUUID = topicTagUUID
        self.topic = topic
        self.isDefault = isDefault
        self.groupPhotoURL = groupPhotoURL
    }
    
    
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["UUID"],
            let groupUUIDJSON = dictionary["GroupUUID"],
            let updatedTimestampServerJSON = dictionary["UpdatedTimestampServer"],
            let topicTagUUIDJSON = dictionary["TopicTagUUID"],
            let topicJSON = dictionary["Topic"],
            let isDefaultJSON = dictionary["IsDefault"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        groupUUID = groupUUIDJSON.stringValue
        updatedTimestampServer = updatedTimestampServerJSON.intValue
        topicTagUUID = topicTagUUIDJSON.stringValue
        topic = topicJSON.stringValue
        isDefault = isDefaultJSON.boolValue
        groupPhotoURL = dictionary["GroupPhotoURL"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["UUID": JSON(uuid), "GroupUUID": JSON(groupUUID), "UpdatedTimestampServer": JSON(updatedTimestampServer), "TopicTagUUID": JSON(topicTagUUID), "Topic": JSON(topic), "IsDefault": JSON(isDefault)]
        if let url = groupPhotoURL {
            dict["GroupPhotoURL"] = JSON(url)
        }
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
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["UUID"],
            let nameJSON = dictionary["Name"],
            let isTopicJSON = dictionary["IsTopic"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        name = nameJSON.stringValue
        isTopic = isTopicJSON.boolValue
    }
    
    // Model
    func toJSON() -> JSON {
        let dict: [String: JSON] = ["UUID": JSON(uuid), "Name": JSON(name), "IsTopic": JSON(isTopic)]
        return JSON(dict)
    }
    
}

func ==(lhs: Tag, rhs: Tag) -> Bool {
    return lhs.uuid == rhs.uuid
}
