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

protocol SearchUIDelegate {
    var searchViewData: OrderedDictionary<SearchViewData, [SearchViewData]> { get set } // groups: convo data map
    
    func convoSelected(uuid: String)
    func groupSelected(uuid: String)
}

protocol SearchVCDelegate {
    func convoSelected(conversation: Conversation)
    func groupSelected(group: Group)
    func keyboardWillShow()
    func keyboardWillHide()
}

protocol SearchTableVCProtocol {
    func reloadSearchResultsData()
}

struct SearchViewData: CustomCollectionViewData, Comparable {
    var uuid: String?
    var text: String
    var photo: UIImage?
    var updatedTimestamp: Int
    var updatedTimeText: String
    var type: Int
    
    var hashValue: Int {
        return uuid?.hashValue ?? 0
    }
    
    init(uuid: String? = nil, text: String, photo: UIImage? = UIImage(named: "rahul_test_pic"), updatedTimestamp: Int, updatedTimeText: String, type: Int) {
        self.uuid = uuid
        self.text = text
        self.photo = photo
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

