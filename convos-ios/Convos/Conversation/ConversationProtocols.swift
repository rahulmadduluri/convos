//
//  ConversationProtocols.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/8/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

struct MessageViewData: Hashable, Comparable {
    var uuid: String?
    var photo: UIImage?
    var text: String
    var isTopLevel: Bool
    var isCollapsed: Bool
    var createdTimestamp: Int
    var createdTimeText: String
    var children: [MessageViewData]
    
    var hashValue: Int {
        return uuid?.hashValue ?? 0
    }
    
    init(uuid: String? = nil, photo: UIImage?, text: String, isTopLevel: Bool = true, isCollapsed: Bool = true, createdTimestamp: Int, createdTimeText: String) {
        self.uuid = uuid
        self.photo = photo
        self.text = text
        self.isTopLevel = isTopLevel
        self.isCollapsed = isCollapsed
        self.createdTimestamp = createdTimestamp
        self.createdTimeText = createdTimeText
        self.children = []
    }
}

func ==(lhs: MessageViewData, rhs: MessageViewData) -> Bool {
    return lhs.uuid == rhs.uuid
}

func <(lhs: MessageViewData, rhs: MessageViewData) -> Bool {
    return lhs.createdTimestamp < rhs.createdTimestamp
}


protocol MessageTableVCDelegate {
    var messageViewData: OrderedDictionary<MessageViewData, [MessageViewData]> { get set }
    func goBack()
}

protocol MessageTableVCProtocol {
    func resetMessageData()
    func addMessage(newMVD: MessageViewData, parentMVD: MessageViewData?)
}

protocol MessageTableCellDelegate {
    func messageTapped(section: Int, row: Int?, mvd: MessageViewData?)
}

protocol MessageUIComponent {
    var delegate: MessageTableCellDelegate? { get set }
    var messageViewData: MessageViewData? { get set }
}
