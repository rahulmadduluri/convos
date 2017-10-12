import UIKit
import SwiftyJSON

class SearchRequest: NSObject, Model {
    
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
            let senderUuidObject = dictionary["senderUuid"],
            let searchTextObject = dictionary["searchText"] else {
                return nil
        }
        senderUuid = senderUuidObject.stringValue
        searchText = searchTextObject.stringValue
    }
    
    // Model
    func toJSON() -> JSON {
        let dict = ["senderUuid": senderUuid, "searchText": searchText]
        return JSON(dict)
    }
}

class SearchResponse: NSObject, Model {
    // vars
    let conversations: [Conversation]
    
    // init
    init (conversations: [Conversation]) {
        self.conversations = conversations
    }
    
    required init?(json: JSON) {
        guard let conversationsJSON = json.array else {
            return nil
        }
        var tempConversations: [Conversation] = []
        for conversationJSON in conversationsJSON {
            if let conversation = Conversation(json: conversationJSON) {
                tempConversations.append(conversation)
            }
        }
        conversations = tempConversations
    }
    
    // Model
    func toJSON() -> JSON {
        var jsonConversations: [JSON] = []
        for conversation in conversations {
            jsonConversations.append(conversation.toJSON())
        }
        return JSON(jsonConversations)
    }
}
