//
//  ConversationViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/5/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

struct MessageViewData {
    var userPhoto: UIImage?
    var text: String?
    var isTopLevel: Bool = true
    var isCollapsed: Bool = false
}

class ConversationViewController: UIViewController, SocketManagerDelegate {
    
    var conversationView: MainConversationView? = nil
    
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        configureConversation()
    }
    
    override func loadView() {
        self.conversationView = MainConversationView()
        self.view = conversationView
    }

    // MARK: SocketManagerDelegate
    
    func received() {
        let messageData = MessageViewData()
        conversationView?.addMessage(data: messageData)
    }
    
    // MARK: Private
    
    fileprivate func configureConversation() {
        if conversationView == nil {
            conversationView = MainConversationView()
        }
    }
    
}
