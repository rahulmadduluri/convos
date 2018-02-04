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
    
    // APIModel
    func toJSON() -> JSON {
        let dict = ["SenderUuid": senderUuid, "SearchText": searchText]
        return JSON(dict)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return SearchRequest(senderUuid: senderUuid, searchText: searchText)
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
    static let _searchRequest = "SearchRequest"
    static let _searchResponse = "SearchResponse"
    static let socketManager: SocketManager = SocketManager.sharedInstance
    
    static func search(searchRequest: SearchRequest) {
        socketManager.send(packetType: _searchRequest, json: searchRequest.toJSON())
    }
}
