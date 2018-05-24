import UIKit
import SwiftyJSON
import SwiftWebSocket

class SearchRequest: NSObject, APIModel {
    
    // vars
    let senderUUID: String
    let searchText: String
    
    // init
    init(senderUUID: String, searchText: String) {
        self.senderUUID = senderUUID
        self.searchText = searchText
    }
    
    required init?(json: JSON) {
        guard let dictionary = json.dictionary,
            let senderUUIDObject = dictionary["SenderUUID"],
            let searchTextObject = dictionary["SearchText"] else {
                return nil
        }
        senderUUID = senderUUIDObject.stringValue
        searchText = searchTextObject.stringValue
    }
    
    // APIModel
    func toJSON() -> JSON {
        let dict = ["SenderUUID": JSON(senderUUID), "SearchText": JSON(searchText)]
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return SearchRequest(senderUUID: senderUUID, searchText: searchText)
    }
}

class SearchResponse: NSObject, APIModel {
    // vars
    let groups: [Group]?
    let errorMsg: String?
    
    // init
    init(groups: [Group]?, errorMsg: String?) {
        self.groups = groups
        self.errorMsg = errorMsg
    }
    
    required init?(json: JSON) {
        guard let dict = json.dictionary else {
            groups = nil
            errorMsg = nil
            return
        }
        if let groupsJSON = dict["Groups"]?.array {
            var tempGroups: [Group] = []
            for g in groupsJSON {
                if let group = Group(json: g) {
                    tempGroups.append(group)
                }
            }
            groups = tempGroups
        } else {
            groups = nil
        }
        errorMsg = dict["ErrorMsg"]?.string
    }
    
    // Model
    func toJSON() -> JSON {
        var dict: [String: JSON] = [:]
        if let groups = groups {
            var groupsJSON: [JSON] = []
            for g in groups {
                groupsJSON.append(g.toJSON())
            }
            dict["Groups"] = JSON(groupsJSON)
        }
        if let errorMsg = errorMsg {
            dict["ErrorMsg"] = JSON(errorMsg)
        }
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return SearchResponse(groups: groups, errorMsg: errorMsg)
    }
}

// Search API

class SearchAPI: NSObject {    
    static func search(searchRequest: SearchRequest) {
        socketManager.send(packetType: _searchRequest, json: searchRequest.toJSON())
    }
}
