//
//  ConversationViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/5/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ConversationViewController: UIViewController, SocketManagerDelegate, MessageTableVCDelegate, UITextFieldDelegate {
    
    var containerView: MainConversationView?
    
    fileprivate var conversationUUID: String = ""
    fileprivate var titleText: String = ""
    fileprivate var messageTableVC = MessageTableViewController()
    // Message Cache
    // First level key: Conversation UUID
    // 2nd level key: top level message
    // 2nd level values: replies
    fileprivate var allCachedMessages: [String: OrderedDictionary<Message, Set<Message>>] = [:]
    // Message view data
    // Key: Top level message
    // Value: List of replies
    fileprivate var messageViewData = OrderedDictionary<MessageViewData, [MessageViewData]>()
    fileprivate let socketManager: SocketManager = SocketManager.sharedInstance
    
    // MARK: UIViewController
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    func received(packet: Packet) {
        switch packet.type {
        case MessageAPI._PullMessagesResponse:
            if let pullMessagesResponse = PullMessagesResponse(json: packet.data) {
                received(response: pullMessagesResponse)
            }
        case MessageAPI._PushMessageResponse:
            if let pushMessageResponse = PushMessageResponse(json: packet.data) {
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
    
    func findMessageViewData(primaryIndex: Int, secondaryIndex: Int?) -> MessageViewData? {
        let messageViewData = getMessageViewData()
        if let j = secondaryIndex {
            return messageViewData[messageViewData.keys[primaryIndex]]?[j]
        }
        return messageViewData.keys[primaryIndex]
    }
    
    func getMessageViewData() -> OrderedDictionary<MessageViewData, [MessageViewData]> {
        return messageViewData
    }
    
    func setMessageViewData(parent: MessageViewData?, mvd: MessageViewData) {
        if let index = messageViewData.keys.index(of: mvd), parent == nil {
            messageViewData.keys[index] = mvd
        }
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
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text,
            let uuid = UserDefaults.standard.object(forKey: "uuid") as? String {
            let pushMessageRequest = PushMessageRequest(conversationUUID: conversationUUID, allText: text, senderUUID: uuid, parentUUID: nil)
            MessageAPI.pushMessage(pushMessageRequest: pushMessageRequest)
            textField.text = ""
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Public
    
    func setConversationInfo(uuid: String, newTitle: String) {
        self.conversationUUID = uuid
        self.titleText = newTitle
        containerView?.topBarView.setTitle(newTitle: newTitle)
    }
    
    // MARK: Private
    
    fileprivate func configureConversation() {
        messageTableVC.messageTableVCDelegate = self
        socketManager.delegates.add(delegate: self)
        
        if let messages = allCachedMessages[conversationUUID] {
            messageViewData = createMessageViewData(messages: messages)
        } else {
            messageViewData = createMessageViewData(messages: OrderedDictionary<Message, Set<Message>>())
        }
        messageTableVC.reloadMessageViewData()
        
        // Do we actually need lastXMessages?
        let request = PullMessagesRequest(conversationUUID: conversationUUID, lastXMessages: 20, latestTimestampServer: nil)
        MessageAPI.pullMessages(pullMessagesRequest: request)
    }
    
    fileprivate func received(response: PullMessagesResponse) {
        // sort messages so that messages with no parent are first
        // reason (I know, hacky): we don't want to insert child before parent
        for m in (response.messages.sorted { $0.parentUUID == nil && $1.parentUUID != nil }) {
            addMessageToCache(m: m)
        }
        if let messages = allCachedMessages[conversationUUID] {
            messageViewData = createMessageViewData(messages: messages)
        }
        messageTableVC.reloadMessageViewData()
    }
    
    fileprivate func received(response: PushMessageResponse) {
        if let m = response.message {
            addMessageToCache(m: m)
        }
        if let messages = allCachedMessages[conversationUUID] {
            messageViewData = createMessageViewData(messages: messages)
        }
        messageTableVC.reloadMessageViewData()
    }
    
    fileprivate func addMessageToCache(m: Message) {
        if allCachedMessages[conversationUUID] == nil {
            allCachedMessages[conversationUUID] = OrderedDictionary<Message, Set<Message>>()
        }
        if allCachedMessages[conversationUUID]![m] == nil {
            // if it has a parent add as a child, otherwise create new entry for 'm'
            if let _ = m.parentUUID {
                for p in allCachedMessages[conversationUUID]!.keys {
                    // if given message is m's parrent && m isn't already in the set
                    if p.uuid == m.parentUUID {
                        allCachedMessages[conversationUUID]![p]?.insert(m)
                    }
                }
            } else {
                allCachedMessages[conversationUUID]![m] = Set<Message>()
            }
        }
    }
    
    fileprivate func createMessageViewData(messages: OrderedDictionary<Message, Set<Message>>) -> OrderedDictionary<MessageViewData, [MessageViewData]> {
        var orderedMessages = OrderedDictionary<MessageViewData, [MessageViewData]>()
        for m1 in messages.keys {
            let replies = messages[m1]?.sorted { $0 < $1 }
            // see comment at top to understand data structure
            orderedMessages[MessageViewData(uuid: m1.uuid, text: m1.allText, photoURI: m1.senderPhotoURI, isTopLevel: true, isCollapsed: false, createdTimestamp: m1.createdTimestampServer, createdTimeText: DateTimeUtilities.minutesAgoText(unixTimestamp: m1.createdTimestampServer))] =
                replies?.map { MessageViewData(uuid: $0.uuid, text: $0.allText, photoURI: $0.senderPhotoURI, isTopLevel: true, isCollapsed: false, createdTimestamp: m1.createdTimestampServer, createdTimeText: DateTimeUtilities.minutesAgoText(unixTimestamp: m1.createdTimestampServer)) }
        }
        return orderedMessages
    }
    
}
