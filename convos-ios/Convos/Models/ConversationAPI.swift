import UIKit
import SwiftyJSON

// MARK: Pull Messages

class PullMessagesRequest: NSObject, APIModel {
    
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

class PullMessagesResponse: NSObject, APIModel {
    
    // vars
    var messages: [Message] = []
    let errorMsg: String?
    
    // init
    required init?(json: JSON) {
        guard let dict = json.dictionary else {
            errorMsg = nil
            return
        }
        if let messagesJSON = dict["messages"]?.array {
            for messageJSON in messagesJSON {
                if let message = Message(json: messageJSON) {
                    messages.append(message)
                }
            }
        }
        errorMsg = dict["errorMsg"]?.string
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = [:]
        var jsonMessages: [JSON] = []
        for message in messages {
            jsonMessages.append(message.toJSON())
        }
        dict["messages"] = JSON(jsonMessages)
        if let errorMsg = errorMsg {
            dict["errorMsg"] = JSON(errorMsg)
        }
        return JSON(dict)
    }
}

// MARK: Push Message

class PushMessageRequest: NSObject, APIModel {
    
    // vars
    let conversationUUID: String
    let fullText: String
    
    // init
    init(conversationUUID: String, fullText: String) {
        self.conversationUUID = conversationUUID
        self.fullText = fullText
    }
    
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

class PushMessageResponse: NSObject, APIModel {
    
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

// Conversation API

class ConversationAPI: NSObject {
    static let socketManager: SocketManager = SocketManager.sharedInstance
    
    static func pushMessage(pushMessageRequest: PushMessageRequest) {
        socketManager.send(json: pushMessageRequest.toJSON())
    }
}
