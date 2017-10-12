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
    fileprivate var latestTimestampServer: Int = 0
    
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
        switch json["type"].stringValue {
        case "pullMessagesResponse":
            let dataJson: JSON = json["data"]
            if let pullMessagesResponse = PullMessagesResponse(json: dataJson) {
                received(response: pullMessagesResponse)
            }
        case "pushMessageResponse":
            let dataJson: JSON = json["data"]
            if let pushMessageResponse = PushMessageResponse(json: dataJson) {
                received(response: pushMessageResponse)
            }
        default:
            break
        }
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
    
    fileprivate func received(response: PullMessagesResponse) {
        if let messages = response.messages {
            // create array of MessageViewData from messages and send
            // find latest server timestamp in messages and store that in memory as latest timestamp
        }
    }
    
    fileprivate func received(response: PushMessageResponse) {
        if let messages = response.message {
            // create MessageViewData from Message and addMessage
        }
    }
}
