//
//  Models.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/26/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON

// MARK: Model Protocols

protocol Model {
    func toJSON() -> JSON
    init?(json: JSON)
}

// MARK: User Models

class User: NSObject, Model {
    
    required init?(json: JSON) {
        
    }
    
    func toJSON() -> JSON {
        return JSON([:])
    }
    
}

// MARK: Message Models



class Message: NSObject, Model {

    /*
    var uuid: String
    var senderUuid: String?
    var messageText: String?
    var serverTimestamp: String?
    var localTimestamp: String?
    var isTopLevel: Bool
    var isCollapsed: Bool
    var children: [Message]
    */

    required init?(json: JSON) {
        
    }
    
    func toJSON() -> JSON {
        return JSON([:])
    }
}

// MARK: Search Models

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
    
    func toJSON() -> JSON {
        let dict = ["senderUuid": senderUuid, "searchText": searchText]
        return JSON(dict)
    }
}

class SearchResponse: NSObject, Model {
        
    required init?(json: JSON) {
        
    }
    
    func toJSON() -> JSON {
        return JSON([:])
    }
}
