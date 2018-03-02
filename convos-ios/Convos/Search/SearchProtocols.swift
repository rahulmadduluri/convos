//
//  SearchProtocols.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/8/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

enum SearchViewType: Int {
    case group
    case newConversation
    case conversation
}

// Search VC / Table VC

protocol SearchVCDelegate {
    func createConvo(group: Group)
    func convoSelected(conversation: Conversation)
    func createGroup()
    func groupSelected(group: Group)
}

protocol SearchTableVCProtocol {
    func reloadSearchViewData()
}

// Search UI Delegates

protocol SearchUIComponent {
    var searchVC: SearchComponentDelegate? { get set }
}

protocol SearchComponentDelegate {
    func getSearchViewData() -> OrderedDictionary<SearchViewData, [SearchViewData]>
    func createConvo(groupUUID: String)
    func convoSelected(uuid: String)
    func createGroup()
    func getGroupForUUID(groupUUID: String) -> Group?
    func groupSelected(groupUUID: String)
}

struct SearchViewData: Hashable, Comparable {
    var uuid: String?
    var text: String
    var photoURI: String?
    var updatedTimestamp: Int
    var updatedTimeText: String
    var type: Int
    
    var hashValue: Int {
        return uuid?.hashValue ?? 0
    }
    
    init(uuid: String? = nil, text: String, photoURI: String? = nil, updatedTimestamp: Int, updatedTimeText: String, type: Int) {
        self.uuid = uuid
        self.text = text
        self.photoURI = photoURI
        self.updatedTimestamp = updatedTimestamp
        self.updatedTimeText = updatedTimeText
        self.type = type
    }
}

func ==(lhs: SearchViewData, rhs: SearchViewData) -> Bool {
    return lhs.uuid == rhs.uuid && lhs.type == lhs.type
}

func <(lhs: SearchViewData, rhs: SearchViewData) -> Bool {
    return lhs.updatedTimestamp < rhs.updatedTimestamp
}
