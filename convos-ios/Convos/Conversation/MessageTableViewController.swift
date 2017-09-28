//
//  MessageTableViewController.swift
//
//  Created by Rahul Madduluri on 9/21/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

struct MessageViewData: CollapsibleTableViewData, Equatable {
    var photo: UIImage?
    var text: String
    var isTopLevel: Bool
    var isCollapsed: Bool
    var children: [CollapsibleTableViewData]
    
    var dateUpdatedText: String?
    
    init(photo: UIImage?, text: String, dateUpdatedText: String?, isTopLevel: Bool = true, isCollapsed: Bool = true) {
        self.photo = photo
        self.text = text
        self.dateUpdatedText = dateUpdatedText
        self.isTopLevel = isTopLevel
        self.isCollapsed = isCollapsed
        self.children = []
    }
}

func ==(lhs: MessageViewData, rhs: MessageViewData) -> Bool {
    return lhs.text == rhs.text && lhs.dateUpdatedText == rhs.dateUpdatedText
}

protocol MessageTableVCDelegate {
    func goBack()
}

protocol MessageTableVCProtocol {
    func loadMessageData(messageData: [MessageViewData])
    func addMessage(newMessage: MessageViewData, parentMessage: MessageViewData?)
}

class MessageTableViewController: CollapsibleTableViewController, MessageTableVCProtocol {
    
    var messageViews: [MessageViewData] = []
    var messageTableVCDelegate: MessageTableVCDelegate? = nil
    
    // MARK: - View Controller
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add test messages
        let testMessage = MessageViewData(photo: UIImage(named: "rahul_test_pic"), text: "YOYOYO", dateUpdatedText: "9/8/17")
        let testMessage2 = MessageViewData(photo: UIImage(named: "rahul_test_pic"), text: "My Name is Jo", dateUpdatedText: "9/8/18")
        let testMessage3 = MessageViewData(photo: UIImage(named: "rahul_test_pic"), text: "I have a big fro", dateUpdatedText: "9/8/19")
        let testMessage4 = MessageViewData(photo: UIImage(named: "praful_test_pic"), text: "What would Bahubali do?", dateUpdatedText: "9/8/20")
        addMessage(newMessage: testMessage, parentMessage: nil)
        addMessage(newMessage: testMessage2, parentMessage: nil)
        addMessage(newMessage: testMessage3, parentMessage: testMessage2)
        addMessage(newMessage: testMessage4, parentMessage: testMessage2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        // Auto resizing the height of the cell
        tableView.estimatedSectionHeaderHeight = 44.0
        tableView.sectionHeaderHeight = 44.0
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        // Other table view config
        tableView.separatorStyle = .none
        
        // Setup Gesture recognizer
        tableView.panGestureRecognizer.addTarget(self, action: #selector(self.respondToPanGesture(gesture:)))
    }
    
    // MARK: Public
    
    func respondToPanGesture(gesture: UIGestureRecognizer) {
        if let panGesture = gesture as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: self.view)
            if (translation.x > 150) {
                messageTableVCDelegate?.goBack()
            }
        }
    }
    
    // MARK: MessageTableVCProtocol
    
    func loadMessageData(messageData: [MessageViewData]) {
        messageViews = messageData
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
    }
    
    func addMessage(newMessage: MessageViewData, parentMessage: MessageViewData?) {
        var foundParent = false
        if let parent = parentMessage {
            for index in 0...messageViews.count-1 {
                if messageViews[index] == parent {
                    messageViews[index].children.append(newMessage)
                    foundParent = true
                }
            }
        }
        
        if !foundParent {
            messageViews.append(newMessage)
        }
        tableView.reloadData()
    }
}

//
// MARK: - Custom Cell & Header
//
extension MessageTableViewController {
    
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConversationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ConversationTableViewCell ??
            ConversationTableViewCell(style: .default, reuseIdentifier: "cell")
        
        if let messageViewData = viewDataModels[indexPath.section].children[indexPath.row] as? MessageViewData {
            cell.textLabel.text = messageViewData.text
            cell.photoImageView.image = messageViewData.photo
        }
        
        return cell
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ConversationTableViewHeader ?? ConversationTableViewHeader(reuseIdentifier: "header")
        
        if let messageViewData = viewDataModels[section] as? MessageViewData {
            header.customTextLabel.text = messageViewData.text
            header.rightSideLabel.text = String(messageViewData.children.count)
        }
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
}
