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
    var messageViewData = OrderedDictionary<MessageViewData, [MessageViewData]>()
    
    fileprivate var uuid: String = ""
    fileprivate var titleText: String = ""
    fileprivate var latestTimestampServer: Int = 0
    
    // map -> date:TopLevelMessage
    fileprivate var topLevelCachedMessages: [String: Message] = [:]
    // map -> topLevelUUID:[date:BottomLevelMessage]
    fileprivate var bottomLevelCachedMessages: [String: [String: Message]] = [:]
    
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
    
    func received(packet: Packet) {
        switch packet.type {
        case ConversationAPI._PullMessagesResponse:
            if let pullMessagesResponse = PullMessagesResponse(json: packet.data) {
                received(response: pullMessagesResponse)
            }
        case ConversationAPI._PushMessageResponse:
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
    
    func getViewData() -> [MessageViewData] {
        let sortedTopMessages: [Message] = topLevelCachedMessages.map({ $0.value }).sorted(by: { $0.createdTimestampServer < $1.createdTimestampServer })
        var finalMVD: [MessageViewData] = []
        
        for m in sortedTopMessages {
            var topMVD: MessageViewData = topLevelMessageViewData(m: m)
            guard let bottomLevelMap: [String: Message] = bottomLevelCachedMessages[m.uuid] else {
                finalMVD.append(topMVD)
                continue
            }
            let sortedBottomMessages: [Message] = bottomLevelMap.keys.sorted(by: { $0 < $1 }).flatMap({ bottomLevelMap[$0] })
            topMVD.children = sortedBottomMessages.map({ bottomLevelMessageViewData(m: $0) })
            
            finalMVD.append(topMVD)
        }
        
        return finalMVD
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
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
        for m in response.messages {
            addMessageToCache(message: m)
            messageTableVC.resetMessageData()
        }
    }
    
    fileprivate func received(response: PushMessageResponse) {
        if let message = response.message {
            addMessageToCache(message: message)
            var pmvd: MessageViewData? = nil
            if let pUUID = message.parentUUID {
                if let pm = topLevelCachedMessages[pUUID] {
                    pmvd = topLevelMessageViewData(m: pm)
                }
            }
            let mvd = pmvd != nil ? bottomLevelMessageViewData(m: message) : topLevelMessageViewData(m: message)
            messageTableVC.addMessage(newMVD: mvd, parentMVD: pmvd)
        }
        
    }
    
    fileprivate func addMessageToCache(message: Message) {
        if let pUUID = message.parentUUID {
            if var map = bottomLevelCachedMessages[pUUID] {
                map[message.uuid] = message
                return
            }
        }
        topLevelCachedMessages[message.uuid] = message
    }
    
    fileprivate func topLevelMessageViewData(m: Message) -> MessageViewData {
        return MessageViewData(photo: nil , text: m.fullText, dateCreatedText: String(m.createdTimestampServer))
    }
    
    fileprivate func bottomLevelMessageViewData(m: Message) -> MessageViewData {
        return MessageViewData(photo: nil, text: m.fullText, dateCreatedText: String(m.createdTimestampServer), isTopLevel: false, isCollapsed: true)
    }
}
