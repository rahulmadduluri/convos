//
//  ConversationViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/5/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON

class ConversationViewController: UIViewController, SocketManagerDelegate, MessageTableVCDelegate, UITextFieldDelegate {
    
    var messageTableVC = MessageTableViewController()
    var containerView: MainConversationView?
    
    fileprivate var uuid: String = ""
    fileprivate var titleText: String = ""
    fileprivate var latestTimestampServer: Int = 0
    
    fileprivate var allCachedMessages: [String: Message] = [:]
    
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        configureConversation()
    }
    
    override func loadView() {
        self.addChildViewController(messageTableVC)
    
        containerView = MainConversationView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        containerView?.bottomBarView.newMessageTextField.delegate = self
        containerView?.messagesTableContainerView = messageTableVC.view
        self.view = containerView
    }
    
    override func viewDidLayoutSubviews() {
        containerView?.topBarView.setTitle(newTitle: titleText)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
    
    func getViewData() -> [MessageViewData] {
        
        var orderedMessageMap: [String: MessageViewData]
        
        for m in allCachedMessages.values {
            if m.isTopLevel {
                orderedMessageMap[m.uuid] = 
            }
        }
        for m in allCachedMessages.values {
            if !m.isTopLevel {
                for om in orderedMessageData {
                    if m.parentUUID == om.
                }
            }
        }
        
        for d in groupViewDataMap.values {
            filteredViewData.append(d)
        }
        return filteredViewData
    }
    
    // MARK: Handle keyboard events
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let cv = containerView,
            let window = cv.window {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            cv.frame = CGRect(x: cv.frame.origin.x,
                                     y: cv.frame.origin.y,
                                     width: cv.frame.width,
                                     height: window.frame.origin.y + window.frame.height - keyboardSize.height)
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if let cv = containerView {
                let viewHeight = cv.frame.height
                containerView?.frame = CGRect(x: cv.frame.origin.x,
                                              y: cv.frame.origin.y,
                                              width: cv.frame.width,
                                              height: viewHeight + keyboardSize.height)
            }
        } else {
            debugPrint("We're about to hide the keyboard and the keyboard size is nil. Now is the rapture.")
        }
    }
    
    // UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            let pushMessageRequest = PushMessageRequest(conversationUUID: uuid, fullText: text)
            ConversationAPI.pushMessage(pushMessageRequest: pushMessageRequest)
            textField.text = ""
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Public
    
    func setConversationInfo(uuid: String, newTitle: String) {
        self.uuid = uuid
        self.titleText = newTitle
        containerView?.topBarView.setTitle(newTitle: newTitle)
    }
    
    // MARK: Private
    
    fileprivate func configureConversation() {
        messageTableVC.messageTableVCDelegate = self
    }
    
    fileprivate func received(response: PullMessagesResponse) {
        
        // create array of MessageViewData from messages and send
        // find latest server timestamp in messages and store that in memory as latest timestamp
    }
    
    fileprivate func received(response: PushMessageResponse) {
        // create MessageViewData from Message and addMessage
        if let message = response.message {
            allCachedMessages[message.uuid] = message
            messageTableVC.addMessage(newMessage: <#T##MessageViewData#>, parentMessage: <#T##MessageViewData?#>)
        }
    }
}
