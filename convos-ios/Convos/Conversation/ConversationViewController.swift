//
//  ConversationViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/5/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON

class ConversationViewController: UIViewController, SocketManagerDelegate, MessageTableVCDelegate {
    
    var messageTableVC = MessageTableViewController()
    var containerView: MainConversationView?
    
    fileprivate var titleText: String = ""
    
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        configureConversation()
    }
    
    override func loadView() {
        self.addChildViewController(messageTableVC)
    
        containerView = MainConversationView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        containerView?.messagesTableContainerView = messageTableVC.view
        self.view = containerView
    }
    
    override func viewDidLayoutSubviews() {
        containerView?.topBarView.setTitle(newTitle: titleText)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        for childVC in self.childViewControllers {
            childVC.removeFromParentViewController()
        }
        
        super.didMove(toParentViewController: parent)
    }
    
    // MARK: SocketManagerDelegate
    
    func received(json: JSON) {
        let message = MessageViewData(photo: nil, text: "", dateUpdatedText: nil)
        let parentMessage = MessageViewData(photo: nil, text: "", dateUpdatedText: nil)
        messageTableVC.addMessage(newMessage: message, parentMessage: parentMessage)
    }
        
    // MARK: MessageTableVCDelegate
    
    func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Public
    
    func setConversationTitle(newTitle: String) {
        self.titleText = newTitle
        containerView?.topBarView.setTitle(newTitle: newTitle)
    }
    
    // MARK: Private
    
    fileprivate func configureConversation() {
        messageTableVC.messageTableVCDelegate = self
    }
    
}
