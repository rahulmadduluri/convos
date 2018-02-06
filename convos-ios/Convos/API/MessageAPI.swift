import UIKit
import SwiftyJSON

// MARK: Pull Messages

class PullMessagesRequest: NSObject, APIModel {
    
    // vars
    let conversationUUID: String
    let lastXMessages: Int
    let latestTimestampServer: Int?
    
    // init
    init(conversationUUID: String, lastXMessages: Int, latestTimestampServer: Int?) {
        self.conversationUUID = conversationUUID
        self.lastXMessages = lastXMessages
        self.latestTimestampServer = latestTimestampServer
    }
    
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let conversationUUIDJSON = dictionary["ConversationUUID"],
            let lastXMessagesJSON = dictionary["SearchText"] else {
            return nil
        }
        conversationUUID = conversationUUIDJSON.stringValue
        lastXMessages = lastXMessagesJSON.intValue
        latestTimestampServer = dictionary["LatestTimestampServer"]?.int
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["ConversationUUID": JSON(conversationUUID), "LastXMessages": JSON(lastXMessages)]
        if let latestTimestampServer = latestTimestampServer {
            dict["LatestTimestampServer"] = JSON(latestTimestampServer)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return PullMessagesRequest(conversationUUID: conversationUUID, lastXMessages: lastXMessages, latestTimestampServer: latestTimestampServer)
    }
}

class PullMessagesResponse: NSObject, APIModel {
    
    // vars
    var messages: [Message] = []
    let errorMsg: String?
    
    // init
    init(messages: [Message], errorMsg: String?) {
        self.messages = messages
        self.errorMsg = errorMsg
    }
    
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
    
    func copy(with zone: NSZone? = nil) -> Any {
        return PullMessagesResponse(messages: messages, errorMsg: errorMsg)
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
    
    // APIModel
    func toJSON() -> JSON {
        let dict: [String: JSON] = ["ConversationUUID": JSON(conversationUUID), "FullText": JSON(fullText)]
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return PushMessageRequest(conversationUUID: conversationUUID, fullText: fullText)
    }
}

class PushMessageResponse: NSObject, APIModel {
    
    // vars
    let message: Message?
    var receiverUUIDs: [String] = []
    let errorMsg: String?
    
    // init
    init(message: Message?, receiverUUIDs: [String], errorMsg: String?) {
        self.message = message
        self.receiverUUIDs = receiverUUIDs
        self.errorMsg = errorMsg
    }
    
    required init?(json: JSON) {
        guard let dict = json.dictionary else {
            message = nil
            errorMsg = nil
            return nil
        }
        if let messageJSON = dict["Message"] {
            message = Message(json: messageJSON)
        } else {
            message = nil
        }
        if let uuids = dict["ReceiverUUIDs"]?.array {
            for i in uuids {
                receiverUUIDs.append(i.stringValue)
            }
        }
        errorMsg = dict["ErrorMsg"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = [:]
        if let message = message {
            dict["Message"] = message.toJSON()
        }
        dict["ReceiverUUIDs"] = JSON(receiverUUIDs)
        if let errorMsg = errorMsg {
            dict["ErrorMsg"] = JSON(errorMsg)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return PushMessageResponse(message: message, receiverUUIDs: receiverUUIDs, errorMsg: errorMsg)
    }
}

// Conversation API

class MessageAPI: NSObject {
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
