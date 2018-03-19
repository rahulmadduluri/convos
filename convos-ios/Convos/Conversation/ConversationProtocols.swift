//
//  ConversationProtocols.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/8/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

protocol ConversationVCDelegate {
    func convoSelected(conversation: Conversation)
}

protocol ConversationComponentDelegate {
    // messages for conversation w/ parent, child relationship
    func getMessageViewData() -> OrderedDictionary<MessageViewData, [MessageViewData]>
    func findMessageViewData(primaryIndex: Int, secondaryIndex: Int?) -> MessageViewData?
    // switch to conversation specified by uuid
    func switchConvoSelected(uuid: String)
    // conversations in this group
    func getConversationViewData() -> [ConversationViewData]
    
    func showSwitcher()
    func hideSwitcher()
}

struct ConversationViewData: Hashable, Comparable {
    var uuid: String
    var text: String
    var photoURI: String?
    var updatedTimestamp: Int
    
    var hashValue: Int {
        return uuid.hashValue
    }
    
    init(uuid: String, text: String, photoURI: String? = nil, updatedTimestamp: Int) {
        self.uuid = uuid
        self.text = text
        self.photoURI = photoURI
        self.updatedTimestamp = updatedTimestamp
    }
}

func ==(lhs: ConversationViewData, rhs: ConversationViewData) -> Bool {
    return lhs.uuid == rhs.uuid
}

func <(lhs: ConversationViewData, rhs: ConversationViewData) -> Bool {
    return lhs.updatedTimestamp < rhs.updatedTimestamp
}

protocol MessageTableVCDelegate: ConversationComponentDelegate {
    func setMessageViewData(parent: MessageViewData?, mvd: MessageViewData)
    func goBack()
}

protocol MessageTableVCProtocol {
    func reloadMessageViewData()
}

protocol ConversationUIComponent {
    var conversationVC: ConversationComponentDelegate? { get set }
}

protocol MessageTableCellDelegate {
    func messageTapped(section: Int, row: Int?)
}

struct MessageViewData: Hashable, Comparable {
    var uuid: String?
    var text: String
    var photoURI: String?
    var isTopLevel: Bool
    var isCollapsed: Bool
    var createdTimestamp: Int
    var createdTimeText: String
    
    var hashValue: Int {
        return uuid?.hashValue ?? 0
    }
    
    init(uuid: String? = nil, text: String, photoURI: String?, isTopLevel: Bool = true, isCollapsed: Bool = true, createdTimestamp: Int, createdTimeText: String) {
        self.uuid = uuid
        self.photoURI = photoURI
        self.text = text
        self.isTopLevel = isTopLevel
        self.isCollapsed = isCollapsed
        self.createdTimestamp = createdTimestamp
        self.createdTimeText = createdTimeText
    }
}

func ==(lhs: MessageViewData, rhs: MessageViewData) -> Bool {
    return lhs.uuid == rhs.uuid
}

func <(lhs: MessageViewData, rhs: MessageViewData) -> Bool {
    return lhs.createdTimestamp < rhs.createdTimestamp
}
