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
    let photoURL: String?
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["uuid"],
            let usernameJSON = dictionary["username"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        username = usernameJSON.stringValue
        photoURL = dictionary["photoURL"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["uuid": JSON(uuid), "username": JSON(username)]
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
    let fullText: String
    let createdTimestampServer: Int
    let isTopLevel: Bool
    let parentUUID: String?

    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["uuid"],
            let senderUUIDJSON = dictionary["senderUUID"],
            let fullTextJSON = dictionary["fullText"],
            let createdTimestampServerJSON = dictionary["createdTimestampServer"],
            let isTopLevelJSON = dictionary["isTopLevel"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        senderUUID = senderUUIDJSON.stringValue
        fullText = fullTextJSON.stringValue
        createdTimestampServer = createdTimestampServerJSON.intValue
        isTopLevel = isTopLevelJSON.boolValue
        parentUUID = dictionary["parentUUID"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["uuid": JSON(uuid), "senderUUID": JSON(senderUUID), "fullText": JSON(fullText), "createdTimestampServer": JSON(createdTimestampServer), "isTopLevel": JSON(isTopLevel)]
        if let parentUUID = parentUUID {
            dict["parentUUID"] = JSON(parentUUID)
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
    let title: String
    let isDefault: Bool
    let groupPhotoURL: String?
    
    // init
    init(uuid: String, groupUUID: String, updatedTimestampServer: Int, topicTagUUID: String, title: String, isDefault: Bool, groupPhotoURL: String? = nil) {
        self.uuid = uuid
        self.groupUUID = groupUUID
        self.updatedTimestampServer = updatedTimestampServer
        self.topicTagUUID = topicTagUUID
        self.title = title
        self.isDefault = isDefault
        self.groupPhotoURL = groupPhotoURL
    }
    
    
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["uuid"],
            let groupUUIDJSON = dictionary["groupUUID"],
            let updatedTimestampServerJSON = dictionary["updatedTimestampServer"],
            let topicTagUUIDJSON = dictionary["topicTagUUID"],
            let titleJSON = dictionary["title"],
            let isDefaultJSON = dictionary["isDefault"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        groupUUID = groupUUIDJSON.stringValue
        updatedTimestampServer = updatedTimestampServerJSON.intValue
        topicTagUUID = topicTagUUIDJSON.stringValue
        title = titleJSON.stringValue
        isDefault = isDefaultJSON.boolValue
        groupPhotoURL = dictionary["groupPhotoURL"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["uuid": JSON(uuid), "groupUUID": JSON(groupUUID), "updatedTimestampServer": JSON(updatedTimestampServer), "topicTagUUID": JSON(topicTagUUID), "title": JSON(title), "isDefault": JSON(isDefault)]
        if let url = groupPhotoURL {
            dict["groupPhotoURL"] = JSON(url)
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
            let uuidJSON = dictionary["uuid"],
            let nameJSON = dictionary["name"],
            let isTopicJSON = dictionary["isTopic"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        name = nameJSON.stringValue
        isTopic = isTopicJSON.boolValue
    }
    
    // Model
    func toJSON() -> JSON {
        let dict: [String: JSON] = ["uuid": JSON(uuid), "name": JSON(name), "isTopic": JSON(isTopic)]
        return JSON(dict)
    }
    
}

func ==(lhs: Tag, rhs: Tag) -> Bool {
    return lhs.uuid == rhs.uuid
}
