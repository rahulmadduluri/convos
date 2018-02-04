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

protocol Model: Hashable {}

protocol APIModel: Model, NSCopying {
    func toJSON() -> JSON
    init?(json: JSON)
}

// MARK: User Models

class User: NSObject, APIModel {
    
    // vars
    let uuid: String
    let username: String
    let photoURI: String?
    
    override var hashValue: Int {
        return uuid.hashValue
    }
    
    // init
    init(uuid: String, username: String, photoURI: String?) {
        self.uuid = uuid
        self.username = username
        self.photoURI = photoURI
    }
    
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["UUID"],
            let usernameJSON = dictionary["Username"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        username = usernameJSON.stringValue
        photoURI = dictionary["PhotoURI"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["UUID": JSON(uuid), "Username": JSON(username)]
        if let photoURI = photoURI {
            dict["PhotoURI"] = JSON(photoURI)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return User(uuid: uuid, username: username, photoURI: photoURI)
    }
    
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.uuid == rhs.uuid
}

// MARK: Message Models

class Message: NSObject, APIModel {

    // vars
    let uuid: String
    let allText: String
    let createdTimestampServer: Int
    let senderUUID: String
    let parentUUID: String?
    let senderPhotoURI: String?
    
    override var hashValue: Int {
        return uuid.hashValue
    }

    // init
    init(uuid: String, allText: String, createdTimestampServer: Int, senderUUID: String, parentUUID: String?, senderPhotoURI: String?) {
        self.uuid = uuid
        self.allText = allText
        self.createdTimestampServer = createdTimestampServer
        self.senderUUID = senderUUID
        self.parentUUID = parentUUID
        self.senderPhotoURI = senderPhotoURI
    }
    
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["UUID"],
            let allTextJSON = dictionary["AllText"],
            let createdTimestampServerJSON = dictionary["CreatedTimestampServer"],
            let senderUUIDJSON = dictionary["SenderUUID"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        allText = allTextJSON.stringValue
        createdTimestampServer = createdTimestampServerJSON.intValue
        senderUUID = senderUUIDJSON.stringValue
        parentUUID = dictionary["ParentUUID"]?.string
        senderPhotoURI = dictionary["SenderPhotoURI"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["UUID": JSON(uuid), "AllText": JSON(allText), "CreatedTimestampServer": JSON(createdTimestampServer), "SenderUUID": JSON(senderUUID)]
        if let parentUUID = parentUUID {
            dict["ParentUUID"] = JSON(parentUUID)
        }
        if let senderPhotoURI = senderPhotoURI {
            dict["SenderPhotoURI"] = JSON(senderPhotoURI)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Message(uuid: uuid, allText: allText, createdTimestampServer: createdTimestampServer, senderUUID: senderUUID, parentUUID: parentUUID, senderPhotoURI: senderPhotoURI)
    }
}

func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.uuid == rhs.uuid
}

func <(lhs: Message, rhs: Message) -> Bool {
    return lhs.createdTimestampServer < rhs.createdTimestampServer
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
    let photoURI: String?
    
    override var hashValue: Int {
        return uuid.hashValue
    }
    
    // init
    init(uuid: String, groupUUID: String, updatedTimestampServer: Int, topicTagUUID: String, topic: String, isDefault: Bool, photoURI: String? = nil) {
        self.uuid = uuid
        self.groupUUID = groupUUID
        self.updatedTimestampServer = updatedTimestampServer
        self.topicTagUUID = topicTagUUID
        self.topic = topic
        self.isDefault = isDefault
        self.photoURI = photoURI
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
        photoURI = dictionary["PhotoURI"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["UUID": JSON(uuid), "GroupUUID": JSON(groupUUID), "UpdatedTimestampServer": JSON(updatedTimestampServer), "TopicTagUUID": JSON(topicTagUUID), "Topic": JSON(topic), "IsDefault": JSON(isDefault)]
        if let url = photoURI {
            dict["PhotoURI"] = JSON(url)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Conversation(uuid: uuid, groupUUID: groupUUID, updatedTimestampServer: updatedTimestampServer, topicTagUUID: topicTagUUID, topic: topic, isDefault: isDefault)
    }
}

func ==(lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.uuid == rhs.uuid
}

func <(lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.updatedTimestampServer < rhs.updatedTimestampServer
}

func >(lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.updatedTimestampServer > rhs.updatedTimestampServer
}

// MARK: Tag Model

class Tag: NSObject, APIModel {
    
    // vars
    let uuid: String
    let name: String
    let isTopic: Bool
    
    // init
    init(uuid: String, name: String, isTopic: Bool) {
        self.uuid = uuid
        self.name = name
        self.isTopic = isTopic
    }
    
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
    
    // API Model
    func toJSON() -> JSON {
        let dict: [String: JSON] = ["UUID": JSON(uuid), "Name": JSON(name), "IsTopic": JSON(isTopic)]
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Tag(uuid: uuid, name: name, isTopic: isTopic)
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
    let photoURI: String?
    var conversations: [Conversation]
    
    override var hashValue: Int {
        return uuid.hashValue
    }
    
    // init
    init(uuid: String, name: String, photoURI: String?, conversations: [Conversation]) {
        self.uuid = uuid
        self.name = name
        self.photoURI = photoURI
        self.conversations = conversations
    }
    
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["UUID"],
            let nameJSON = dictionary["Name"],
            let conversationsJSON = dictionary["Conversations"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        name = nameJSON.stringValue
        conversations = []
        photoURI = dictionary["PhotoURI"]?.stringValue
        
        for cj in conversationsJSON.arrayValue {
            if let c = Conversation(json: cj) {
                conversations.append(c)
            }
        }
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["UUID": JSON(uuid), "Name": JSON(name), "Conversations": JSON(conversations)]
        if let url = photoURI {
            dict["PhotoURI"] = JSON(url)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Group(uuid: uuid, name: name, photoURI: photoURI, conversations: conversations)
    }
    
}

func ==(lhs: Group, rhs: Group) -> Bool {
    return lhs.uuid == rhs.uuid
}

func <(lhs: Group, rhs: Group) -> Bool {
    guard let a = lhs.conversations.sorted(by: <).first,
        let b = rhs.conversations.sorted(by: <).first else {
        return false
    }
    return a < b
}

