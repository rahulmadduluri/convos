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
            let conversationUUIDJSON = dictionary["ConversationUUID"],
            let lastXMessagesJSON = dictionary["SearchText"] else {
            return nil
        }
        conversationUUID = conversationUUIDJSON.stringValue
        lastXMessages = lastXMessagesJSON.intValue
        earliestServerTimestamp = dictionary["EarliestServerTimestamp"]?.int
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["ConversationUUID": JSON(conversationUUID), "LastXMessages": JSON(lastXMessages)]
        if let earliestServerTimestamp = earliestServerTimestamp {
            dict["EarliestServerTimestamp"] = JSON(earliestServerTimestamp)
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
        if let messagesJSON = dict["Messages"]?.array {
            for messageJSON in messagesJSON {
                if let message = Message(json: messageJSON) {
                    messages.append(message)
                }
            }
        }
        errorMsg = dict["ErrorMsg"]?.string
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = [:]
        var jsonMessages: [JSON] = []
        for message in messages {
            jsonMessages.append(message.toJSON())
        }
        dict["Messages"] = JSON(jsonMessages)
        if let errorMsg = errorMsg {
            dict["ErrorMsg"] = JSON(errorMsg)
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
            let conversationUUIDJSON = dictionary["ConversationUUID"],
            let fullTextJSON = dictionary["FullText"] else {
            return nil
        }
        conversationUUID = conversationUUIDJSON.stringValue
        fullText = fullTextJSON.stringValue
    }
    
    // Model
    func toJSON() -> JSON {
        let dict: [String: JSON] = ["ConversationUUID": JSON(conversationUUID), "FullText": JSON(fullText)]
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
        if let messageJSON = dictionary["Message"] {
            message = Message(json: messageJSON)
        } else {
            message = nil
        }
        errorMsg = dictionary["ErrorMsg"]?.string
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = [:]
        if let message = message {
            dict["Message"] = message.toJSON()
        }
        if let errorMsg = errorMsg {
            dict["ErrorMsg"] = JSON(errorMsg)
        }
        return JSON(dict)
    }
}

// Conversation API

class ConversationAPI: NSObject {
    static let _PushMessageRequest = "PushMessageRequest"
    static let _PushMessageResponse = "PushMessageResponse"
    static let _PullMessagesRequest = "PullMessagesRequest"
    static let _PullMessagesResponse = "PullMessagesResponse"
    static let socketManager: SocketManager = SocketManager.sharedInstance
    
    static func pushMessage(pushMessageRequest: PushMessageRequest) {
        socketManager.send(packetType: _PushMessageRequest, json: pushMessageRequest.toJSON())
    }
    
    static func pullMessages(pullMessagesRequest: PullMessagesRequest) {
        socketManager.send(packetType: _PullMessagesRequest, json: pullMessagesRequest.toJSON())
    }
}
