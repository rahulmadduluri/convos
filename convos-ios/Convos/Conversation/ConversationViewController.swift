//
//  ConversationViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/5/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

struct MessageViewData: Equatable {
    var userPhoto: UIImage?
    var messageText: String?
    var dateUpdatedText: String?
    var isTopLevel: Bool = true
    var isCollapsed: Bool = false
    var children: [MessageViewData] = []
    
    init(userPhoto: UIImage?, messageText: String?, dateUpdatedText: String?) {
        self.userPhoto = userPhoto
        self.messageText = messageText
        self.dateUpdatedText = dateUpdatedText
    }
}

func ==(lhs: MessageViewData, rhs: MessageViewData) -> Bool {
    return lhs.messageText == rhs.messageText && lhs.dateUpdatedText == rhs.dateUpdatedText
}

class ConversationViewController: UIViewController, SocketManagerDelegate {
    
    var containerView: MainConversationView? = nil
    var conversationTableVC = MessageTableViewController()
    
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        configureConversation()
    }
    
    override func loadView() {
        self.addChildViewController(conversationTableVC)
    
        containerView = MainConversationView()
        containerView?.messagesTableContainerView = conversationTableVC.view
        self.view = containerView
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        self.childViewControllers.last?.removeFromParentViewController()
        
        super.didMove(toParentViewController: parent)
    }
    
    // MARK: SocketManagerDelegate
    
    func received(json: Dictionary<String, Any>) {
        let message = MessageViewData(userPhoto: nil, messageText: nil, dateUpdatedText: nil)
        let parentMessage = MessageViewData(userPhoto: nil, messageText: nil, dateUpdatedText: nil)
        conversationTableVC.addMessage(newMessage: message, parentMessage: parentMessage)
    }
    
    func send(json: Dictionary<String, Any>) {
        // package message view data into a JSON query object and send
    }
    
    // MARK: Private
    
    fileprivate func configureConversation() {
    }
    
}
