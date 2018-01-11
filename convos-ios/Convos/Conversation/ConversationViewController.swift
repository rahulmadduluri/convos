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
    
    var containerView: MainConversationView?
    
    fileprivate var uuid: String = ""
    fileprivate var titleText: String = ""
    fileprivate var messageTableVC = MessageTableViewController()
    fileprivate var allCachedMessages: [Message: [Message]] = [:]
    fileprivate var filteredMessages = OrderedDictionary<Message, [Message]>()
    
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
    
    func findMessageViewData(primaryIndex: Int, secondaryIndex: Int?) {
        if let j = secondaryIndex {
            return messageViewData[messageViewData.keys[primaryIndex]][j]
        }
        return messageViewData.keys[primaryIndex]
    }
    
    func getMessageViewData() -> OrderedDictionary<MessageViewData, [MessageViewData]> {
        var res = OrderedDictionary<MessageViewData, [MessageViewData]>()
        for g in filteredGroups.keys {
            res[SearchViewData(uuid: g.uuid, text: g.name, photo: nil, type: SearchViewType.group.rawValue)] =
                cs.map { SearchViewData(uuid: $0.uuid, text: $0.topic, photo: nil, type: SearchViewType.conversation.rawValue) }
        }
        return res
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

        testingSetup()
        messageTableVC.resetMessageData()
    }
    
    fileprivate func received(response: PullMessagesResponse) {
        for m in response.messages {
            addMessageToCache(message: m)
            messageTableVC.resetMessageData()
        }
    }
    
    fileprivate func received(response: PushMessageResponse) {
        if let m = response.message {
            addMessageToCache(m)
            messageTableVC.resetMessageData()
        }
    }
    
    fileprivate func addMessageToCache(m: Message) {
        if allCachedMessages[m] == nil {
            if let pUUID = m.parentUUID {
                let foundParent = false
                // if parent exists in keys, append to parent
                for p in allCachedMessages.keys {
                    if p.uuid == pUUID {
                        foundParent = true
                        p.append(m)
                    }
                }
                if foundParent == false {
                    print("ERROR: could not find message parent!!! make call to pull messages")
                }
            } else {
                allCachedMessages[m] = []
            }
        }
    }
    
    fileprivate func topLevelMessageViewData(m: Message) -> MessageViewData {
        return MessageViewData(photo: nil , text: m.fullText, dateCreatedText: String(m.createdTimestampServer))
    }
    
    fileprivate func bottomLevelMessageViewData(m: Message) -> MessageViewData {
        return MessageViewData(photo: nil, text: m.fullText, dateCreatedText: String(m.createdTimestampServer), isTopLevel: false, isCollapsed: true)
    }
            
    fileprivate func testingSetup() {
        // Add test messages
        let testMessage = Message(uuid: "1", photo: UIImage(named: "rahul_test_pic"), text: "yoyoyoyoyoyoyoyoyo", createdTimestamp: 0, createdTimeText: "9/8/17")
        let testMessage2 = Message(uuid: "2", photo: UIImage(named: "rahul_test_pic"), text: "My Name is Jo", createdTimestamp: 1, createdTimeText: "9/8/18")
        let testMessage3 = Message(photo: UIImage(named: "rahul_test_pic"), text: "I have a big fro", createdTimestamp: 2, createdTimeText: "9/8/19")
        let testMessage4 = Message(photo: UIImage(named: "praful_test_pic"), text: "testtest", createdTimestamp: 3, createdTimeText: "9/8/20")
        let testMessage5 = Message(photo: UIImage(named: "praful_test_pic"), text: "teststststststststststets", createdTimestamp: 4, createdTimeText: "9/9/20")
        allCachedMessages[testMessage] = [testMessage3]
        allCachedMessages[testMessage2] = [testMessage4, testMessage5]
        
        filteredMessages.removeAll()
        for (k, v) in allCachedMessages {
            filteredMessages[k] = v
        }
    }

}
