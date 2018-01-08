//
//  ConversationProtocols.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/8/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

struct MessageViewData: Equatable, Comparable {
    var uuid: String?
    var photo: UIImage?
    var text: String
    var isTopLevel: Bool
    var isCollapsed: Bool
    var children: [MessageViewData]
    var dateCreatedText: String
    
    init(photo: UIImage?, text: String, dateCreatedText: String, isTopLevel: Bool = true, isCollapsed: Bool = true) {
        self.photo = photo
        self.text = text
        self.dateCreatedText = dateCreatedText
        self.isTopLevel = isTopLevel
        self.isCollapsed = isCollapsed
        self.children = []
    }
}

func ==(lhs: MessageViewData, rhs: MessageViewData) -> Bool {
    return lhs.uuid == rhs.uuid
}

func <(lhs: MessageViewData, rhs: MessageViewData) -> Bool {
    return lh.dateCreated
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
    func messageTapped(section: Int, row: Int?, mvd: MessageViewData)
}

protocol MessageUIComponent {
    var delegate: MessageTableCellDelegate? { get set }
    var messageViewData: MessageViewData
}
