//
//  ConversationInfoProtocols.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/25/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

protocol ConversationInfoVCDelegate {
    func conversationCreated()
}

protocol ConversationInfoComponentDelegate {
    var isNewConversation: Bool { get }
    
    func getConversation() -> Conversation?
    func conversationPhotoEdited(image: UIImage)
    func conversationTopicEdited(topic: String)
    func conversationCreated(topic: String?, photo: UIImage?)
    func presentAlertOption(tag: Int)
}

protocol ConversationInfoUIComponent {
    var conversationInfoVC: ConversationInfoComponentDelegate? { get set }
}
