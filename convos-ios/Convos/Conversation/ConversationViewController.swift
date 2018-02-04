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
    
    fileprivate var uuid: String = ""
    fileprivate var titleText: String = ""
    fileprivate var messageTableVC = MessageTableViewController()
    fileprivate var allCachedMessages: [Message: [Message]] = [:]
    fileprivate var filteredMessages = OrderedDictionary<Message, [Message]>()
    fileprivate var messageViewData = OrderedDictionary<MessageViewData, [MessageViewData]>()
    
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
        messageTableVC.reloadMessageViewData()
        
        // Do we actually need lastXMessages?
        let request = PullMessagesRequest(conversationUUID: "uuid-1", lastXMessages: 10, latestTimestampServer: nil)
        ConversationAPI.pullMessages(pullMessagesRequest: request)
    }
    
    fileprivate func received(response: PullMessagesResponse) {
        for m in response.messages {
            addMessageToCache(m: m)
        }
        messageViewData = createMessageViewData()
        messageTableVC.reloadMessageViewData()
    }
    
    fileprivate func received(response: PushMessageResponse) {
        if let m = response.message {
            addMessageToCache(m: m)
        }
        messageViewData = createMessageViewData()
        messageTableVC.reloadMessageViewData()
    }
    
    fileprivate func addMessageToCache(m: Message) {
        if allCachedMessages[m] == nil {
            if let pUUID = m.parentUUID {
                var foundParent = false
                // if parent exists in keys, append to parent
                for p in allCachedMessages.keys {
                    if p.uuid == pUUID {
                        foundParent = true
                        allCachedMessages[p]?.append(m)
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
    
    fileprivate func createMessageViewData() -> OrderedDictionary<MessageViewData, [MessageViewData]> {
        var res = OrderedDictionary<MessageViewData, [MessageViewData]>()
        for m1 in filteredMessages.keys {
            res[MessageViewData(uuid: m1.uuid, text: m1.allText, photoURI: m1.senderPhotoURI, isTopLevel: true, isCollapsed: false, createdTimestamp: m1.createdTimestampServer, createdTimeText: DateTimeUtilities.minutesAgoText(unixTimestamp: m1.createdTimestampServer))] =
                filteredMessages[m1]?.map { MessageViewData(uuid: $0.uuid, text: $0.allText, photoURI: $0.senderPhotoURI, isTopLevel: true, isCollapsed: false, createdTimestamp: m1.createdTimestampServer, createdTimeText: DateTimeUtilities.minutesAgoText(unixTimestamp: m1.createdTimestampServer)) }
        }
        return res
    }
    
    fileprivate func testingSetup() {
        // Add test messages
        let testMessage = Message(uuid: "1", allText: "yoyoyoyoyoyoyoyoyo", createdTimestampServer: 0, senderUUID: "1", parentUUID: nil, senderPhotoURI: "rahul_prof")
        let testMessage2 = Message(uuid: "2", allText: "My Name is Jo!", createdTimestampServer: 1, senderUUID: "2",  parentUUID: nil, senderPhotoURI: "prafulla_prof")
        let testMessage3 = Message(uuid: "3", allText: "I have a big fro", createdTimestampServer: 2, senderUUID: "1", parentUUID: nil, senderPhotoURI: "rahul_prof")
        let testMessage4 = Message(uuid: "4", allText: "reply#1", createdTimestampServer: 2, senderUUID: "2", parentUUID: "2", senderPhotoURI: "prafulla_prof")
        let testMessage5 = Message(uuid: "5", allText: "reply#2", createdTimestampServer: 7, senderUUID: "2", parentUUID: "2", senderPhotoURI: "prafulla_prof")
        allCachedMessages[testMessage] = []
        allCachedMessages[testMessage2] = [testMessage4, testMessage5]
        allCachedMessages[testMessage3] = []
        
        filteredMessages.removeAll()
        for (k, v) in allCachedMessages {
            filteredMessages[k] = v
        }
        
        messageViewData = createMessageViewData()
    }

}
