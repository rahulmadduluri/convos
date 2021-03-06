//
//  APIModels.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/25/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol APIModel: Model, NSCopying {
    func toJSON() -> JSON
    init?(json: JSON)
}

// MARK: User Models

class User: NSObject, APIModel {
    
    // vars
    let uuid: String
    let name: String
    let handle: String
    let photoURI: String?
    
    override var hashValue: Int {
        return uuid.hashValue
    }
    
    // init
    init(uuid: String, name: String, handle: String, photoURI: String?) {
        self.uuid = uuid
        self.name = name
        self.handle = handle
        self.photoURI = photoURI
    }
    
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["UUID"],
            let nameJSON = dictionary["Name"],
            let handleJSON = dictionary["Handle"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        name = nameJSON.stringValue
        handle = handleJSON.stringValue
        photoURI = dictionary["PhotoURI"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["UUID": JSON(uuid), "Name": JSON(name), "Handle": JSON(handle)]
        if let photoURI = photoURI {
            dict["PhotoURI"] = JSON(photoURI)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return User(uuid: uuid, name: name, handle: handle, photoURI: photoURI)
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
    
    override var hash: Int {
        return uuid.hash
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? Message {
            return uuid == object.uuid
        } else {
            return false
        }
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
    var topic: String
    var photoURI: String?
    
    override var hashValue: Int {
        return uuid.hashValue
    }
    
    // init
    init(uuid: String, groupUUID: String, updatedTimestampServer: Int, topic: String, photoURI: String? = nil) {
        self.uuid = uuid
        self.groupUUID = groupUUID
        self.updatedTimestampServer = updatedTimestampServer
        self.topic = topic
        self.photoURI = photoURI
    }
    
    
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["UUID"],
            let groupUUIDJSON = dictionary["GroupUUID"],
            let updatedTimestampServerJSON = dictionary["UpdatedTimestampServer"],
            let topicJSON = dictionary["Topic"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        groupUUID = groupUUIDJSON.stringValue
        updatedTimestampServer = updatedTimestampServerJSON.intValue
        topic = topicJSON.stringValue
        photoURI = dictionary["PhotoURI"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["UUID": JSON(uuid), "GroupUUID": JSON(groupUUID), "UpdatedTimestampServer": JSON(updatedTimestampServer), "Topic": JSON(topic)]
        if let url = photoURI {
            dict["PhotoURI"] = JSON(url)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Conversation(uuid: uuid, groupUUID: groupUUID, updatedTimestampServer: updatedTimestampServer, topic: topic)
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
    var uuid: String
    var name: String
    var handle: String
    var photoURI: String?
    var conversations: [Conversation]
    
    override var hashValue: Int {
        return uuid.hashValue
    }
    
    override var hash: Int {
        return uuid.hash
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? Group {
            return uuid == object.uuid
        } else {
            return false
        }
    }
    
    // init
    init(uuid: String, name: String, handle: String, photoURI: String?, conversations: [Conversation]) {
        self.uuid = uuid
        self.name = name
        self.handle = handle
        self.photoURI = photoURI
        self.conversations = conversations
    }
    
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidJSON = dictionary["UUID"],
            let nameJSON = dictionary["Name"],
            let handleJSON = dictionary["Handle"],
            let conversationsJSON = dictionary["Conversations"] else {
                return nil
        }
        uuid = uuidJSON.stringValue
        name = nameJSON.stringValue
        handle = handleJSON.stringValue
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
        var dict: [String: JSON] = ["UUID": JSON(uuid), "Name": JSON(name), "Handle": JSON(handle), "Conversations": JSON(conversations)]
        if let url = photoURI {
            dict["PhotoURI"] = JSON(url)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Group(uuid: uuid, name: name, handle: handle, photoURI: photoURI, conversations: conversations)
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

