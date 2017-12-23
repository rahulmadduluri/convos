import UIKit
import SwiftyJSON
import SwiftWebSocket

class SearchRequest: NSObject, APIModel {
    
    // vars
    let senderUuid: String
    let searchText: String
    
    // init
    init(senderUuid: String, searchText: String) {
        self.senderUuid = senderUuid
        self.searchText = searchText
    }
    
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let senderUuidObject = dictionary["SenderUuid"],
            let searchTextObject = dictionary["SearchText"] else {
                return nil
        }
        senderUuid = senderUuidObject.stringValue
        searchText = searchTextObject.stringValue
    }
    
    // Model
    func toJSON() -> JSON {
        let dict = ["SenderUuid": senderUuid, "SearchText": searchText]
        return JSON(dict)
    }
}

class SearchResponse: NSObject, APIModel {
    // vars
    let conversations: [Conversation]?
    let errorMsg: String?
    
    // init
    required init?(json: JSON) {
        guard let dict = json.dictionary else {
            conversations = nil
            errorMsg = nil
            return
        }
        if let conversationsJSON = dict["Conversations"]?.array {
            var tempConversations: [Conversation] = []
            for c in conversationsJSON {
                if let conversation = Conversation(json: c) {
                    tempConversations.append(conversation)
                }
            }
            conversations = tempConversations
        } else {
            conversations = nil
        }
        errorMsg = dict["ErrorMsg"]?.string
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = [:]
        if let conversations = conversations {
            var conversationsJSON: [JSON] = []
            for conversation in conversations {
                conversationsJSON.append(conversation.toJSON())
            }
            dict["Conversations"] = JSON(conversationsJSON)
        }
        if let errorMsg = errorMsg {
            dict["ErrorMsg"] = JSON(errorMsg)
        }
        return JSON(dict)
    }
}

// Search API

class SearchAPI: NSObject {
    static let _searchRequest = "SearchRequest"
    static let _searchResponse = "SearchResponse"
    static let socketManager: SocketManager = SocketManager.sharedInstance
    
    static func search(searchRequest: SearchRequest) {
        socketManager.send(packetType: _searchRequest, json: searchRequest.toJSON())
    }
}
