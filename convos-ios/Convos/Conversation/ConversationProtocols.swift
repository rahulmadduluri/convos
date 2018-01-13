//
//  ConversationProtocols.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/8/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

extension Message: Comparable {}

protocol MessageUIDelegate {
    func getMessageViewData() -> OrderedDictionary<MessageViewData, [MessageViewData]>
    func findMessageViewData(primaryIndex: Int, secondaryIndex: Int?) -> MessageViewData?
}

protocol MessageTableVCDelegate: MessageUIDelegate {
    func setMessageViewData(parent: MessageViewData?, mvd: MessageViewData)
    func goBack()
}

protocol MessageTableVCProtocol {
    func reloadMessageViewData()
}

protocol MessageUIComponent {
    var delegate: MessageTableCellDelegate? { get set }
}

protocol MessageTableCellDelegate {
    func messageTapped(section: Int, row: Int?)
}

struct MessageViewData: Hashable, Comparable {
    var uuid: String?
    var text: String
    var photo: UIImage?
    var isTopLevel: Bool
    var isCollapsed: Bool
    var createdTimestamp: Int
    var createdTimeText: String
    
    var hashValue: Int {
        return uuid?.hashValue ?? 0
    }
    
    init(uuid: String? = nil, text: String, photo: UIImage?, isTopLevel: Bool = true, isCollapsed: Bool = true, createdTimestamp: Int, createdTimeText: String) {
        self.uuid = uuid
        self.photo = photo
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
