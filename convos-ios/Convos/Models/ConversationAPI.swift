import UIKit
import SwiftyJSON

// MARK: Pull Messages

class PullMessagesRequest: NSObject, Model {
    
    // vars
    let conversationUUID: String
    let lastXMessages: Int
    let earliestServerTimestamp: Int?
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let conversationUUIDJSON = dictionary["conversationUUID"],
            let lastXMessagesJSON = dictionary["searchText"] else {
            return nil
        }
        conversationUUID = conversationUUIDJSON.stringValue
        lastXMessages = lastXMessagesJSON.intValue
        earliestServerTimestamp = dictionary["earliestServerTimestamp"]?.int
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["conversationUUID": JSON(conversationUUID), "lastXMessages": JSON(lastXMessages)]
        if let earliestServerTimestamp = earliestServerTimestamp {
            dict["earliestServerTimestamp"] = JSON(earliestServerTimestamp)
        }
        return JSON(dict)
    }
}

class PullMessagesResponse: NSObject, Model {
    
    // vars
    let messages: [Message]?
    let errorMsg: String?
    
    // init
    required init?(json: JSON) {
        guard let dict = json.dictionary else {
            messages = nil
            errorMsg = nil
            return
        }
        if let messagesJSON = dict["messages"]?.array {
            var tempMessages: [Message] = []
            for messageJSON in messagesJSON {
                if let message = Message(json: messageJSON) {
                    tempMessages.append(message)
                }
            }
            messages = tempMessages
        } else {
            messages = nil
        }
        errorMsg = dict["errorMsg"]?.string
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = [:]
        if let messages = messages {
            var jsonMessages: [JSON] = []
            for message in messages {
                jsonMessages.append(message.toJSON())
            }
            dict["messages"] = JSON(jsonMessages)
        }
        if let errorMsg = errorMsg {
            dict["errorMsg"] = JSON(errorMsg)
        }
        return JSON(dict)
    }
}

// MARK: Push Message

class PushMessageRequest: NSObject, Model {
    
    // vars
    let conversationUUID: String
    let fullText: String
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let conversationUUIDJSON = dictionary["conversationUUID"],
            let fullTextJSON = dictionary["fullText"] else {
            return nil
        }
        conversationUUID = conversationUUIDJSON.stringValue
        fullText = fullTextJSON.stringValue
    }
    
    // Model
    func toJSON() -> JSON {
        let dict: [String: JSON] = ["conversationUUID": JSON(conversationUUID), "fullText": JSON(fullText)]
        return JSON(dict)
    }
}

class PushMessageResponse: NSObject, Model {
    
    // vars
    let message: Message?
    let errorMsg: String?
    
    // init
    required init?(json: JSON) {
        guard let dictionary = json.dictionary else {
            message = nil
            errorMsg = nil
            return nil
        }
        if let messageJSON = dictionary["message"] {
            message = Message(json: messageJSON)
        } else {
            message = nil
        }
        errorMsg = dictionary["errorMsg"]?.string
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = [:]
        if let message = message {
            dict["message"] = message.toJSON()
        }
        if let errorMsg = errorMsg {
            dict["errorMsg"] = JSON(errorMsg)
        }
        return JSON(dict)
    }
}
