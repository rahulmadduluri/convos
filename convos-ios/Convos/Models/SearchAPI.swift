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
    
    // init
    required init?(json: JSON) {
        
    }
    
    // Model
    func toJSON() -> JSON {
        return JSON([:])
    }
}
