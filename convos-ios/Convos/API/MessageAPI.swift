import UIKit
import SwiftyJSON

// MARK: Pull Messages

class PullMessagesRequest: NSObject, APIModel {
    
    // vars
    let userUUID: String
    let conversationUUID: String
    let groupUUID: String
    let lastXMessages: Int
    let latestTimestampServer: Int?
    
    // init
    init(userUUID: String, conversationUUID: String, groupUUID: String, lastXMessages: Int, latestTimestampServer: Int?) {
        self.userUUID = userUUID
        self.conversationUUID = conversationUUID
        self.groupUUID = groupUUID
        self.lastXMessages = lastXMessages
        self.latestTimestampServer = latestTimestampServer
    }
    
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let userUUIDJSON = dictionary["UserUUID"],
            let conversationUUIDJSON = dictionary["ConversationUUID"],
            let groupUUIDJSON = dictionary["GroupUUID"],
            let lastXMessagesJSON = dictionary["SearchText"] else {
            return nil
        }
        userUUID = userUUIDJSON.stringValue
        conversationUUID = conversationUUIDJSON.stringValue
        groupUUID = groupUUIDJSON.stringValue
        lastXMessages = lastXMessagesJSON.intValue
        latestTimestampServer = dictionary["LatestTimestampServer"]?.int
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["UserUUID": JSON(userUUID), "ConversationUUID": JSON(conversationUUID), "GroupUUID": JSON(groupUUID), "LastXMessages": JSON(lastXMessages)]
        if let latestTimestampServer = latestTimestampServer {
            dict["LatestTimestampServer"] = JSON(latestTimestampServer)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return PullMessagesRequest(userUUID: userUUID, conversationUUID: conversationUUID, groupUUID: groupUUID, lastXMessages: lastXMessages, latestTimestampServer: latestTimestampServer)
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
    let groupUUID: String
    let allText: String
    let senderUUID: String
    let parentUUID: String?
    
    // init
    init(conversationUUID: String, groupUUID: String, allText: String, senderUUID: String, parentUUID: String?) {
        self.conversationUUID = conversationUUID
        self.groupUUID = groupUUID
        self.allText = allText
        self.senderUUID = senderUUID
        self.parentUUID = parentUUID
    }
    
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let conversationUUIDJSON = dictionary["ConversationUUID"],
            let groupUUIDJSON = dictionary["GroupUUID"],
            let allTextJSON = dictionary["AllText"],
            let senderUUIDJSON = dictionary["SenderUUID"] else {
            return nil
        }
        conversationUUID = conversationUUIDJSON.stringValue
        groupUUID = groupUUIDJSON.stringValue
        allText = allTextJSON.stringValue
        senderUUID = senderUUIDJSON.stringValue
        parentUUID = dictionary["ParentUUID"]?.string
    }
    
    // APIModel
    func toJSON() -> JSON {
        var dict: [String: JSON] = ["ConversationUUID": JSON(conversationUUID), "GroupUUID": JSON(groupUUID), "AllText": JSON(allText), "SenderUUID": JSON(senderUUID)]
        if let parentUUID = parentUUID {
            dict["ParentUUID"] = JSON(parentUUID)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return PushMessageRequest(conversationUUID: conversationUUID, groupUUID: groupUUID, allText: allText, senderUUID: senderUUID, parentUUID: parentUUID)
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
