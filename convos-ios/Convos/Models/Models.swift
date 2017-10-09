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

    var uuid: String
    var senderUUID: String
    var messageText: String?
    var serverTimestamp: String?
    var createdLocalTimestamp: String?
    var isTopLevel: Bool
    var children: [Message]

    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let uuidObject = dictionary["uuid"],
            let senderUUIDObject = dictionary["senderUUID"] else {
                return nil
        }
        uuid = uuidObject.stringValue
        senderUUID = senderUUIDObject.stringValue
        messageText = dictionary["messageText"]?.stringValue
        serverTimestamp = dictionary["serverTimestamp"]?.stringValue
        createdLocalTimestamp = dictionary["createdLocalTimestamp"]?.stringValue
        isTopLevel = dictionary["isTopLevel"]?.boolValue ?? true
        children = []
        if let receivedChildren = dictionary["children"]?.arrayValue {
            for child in receivedChildren {
                guard let newMessage = Message.init(json: child) else {
                    continue
                }
                children.append(newMessage)
            }
        }
    }
    
    func toJSON() -> JSON {
        var dict: [String: Any?] = ["uuid": uuid, "senderUUID": senderUUID, "messageText": messageText, "serverTimestamp": serverTimestamp, "createdLocalTimestamp": createdLocalTimestamp, "isTopLevel": isTopLevel]
        var jsonChildren: [JSON] = []
        for child in children {
            jsonChildren.append(child.toJSON())
        }
        dict["children"] = jsonChildren
        return JSON(dict)
    }
}
