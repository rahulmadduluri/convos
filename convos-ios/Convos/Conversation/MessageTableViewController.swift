//
//  CollapsibleTableViewController.swift
//
//  Created by Yong Su on 5/30/16.
//  Copyright © 2016 Yong Su. All rights reserved.
//
//  Modified by Rahul Madduluri on 7/21/17.

import UIKit

protocol MessageTableVCProtocol {
    func loadMessageData(messageData: [MessageViewData])
    func addMessage(newMessage: MessageViewData, parentMessage: MessageViewData?)
}

class MessageTableViewController: UITableViewController, MessageTableVCProtocol {
    
    var messageViews: [MessageViewData] = []
    var messageTableVCDelegate: MessageTableVCDelegate? = nil
    
    // MARK: - View Controller
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add test messages
        let testMessage = MessageViewData(userPhoto: UIImage(named: "rahul_test_pic"), messageText: "YOYOYO", dateUpdatedText: "9/8/17")
        let testMessage2 = MessageViewData(userPhoto: UIImage(named: "rahul_test_pic"), messageText: "My Name is Jo", dateUpdatedText: "9/8/18")
        let testMessage3 = MessageViewData(userPhoto: UIImage(named: "rahul_test_pic"), messageText: "I have a big fro", dateUpdatedText: "9/8/19")
        let testMessage4 = MessageViewData(userPhoto: UIImage(named: "praful_test_pic"), messageText: "What would Bahubali do?", dateUpdatedText: "9/8/20")
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
// MARK: - View Controller DataSource and Delegate
//
extension MessageTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return messageViews.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageViews[section].isCollapsed ? 0 : messageViews[section].children.count
    }
    
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CollapsibleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CollapsibleTableViewCell ??
            CollapsibleTableViewCell(style: .default, reuseIdentifier: "cell")
        
        let messageViewData: MessageViewData = messageViews[indexPath.section].children[indexPath.row]
        
        cell.messageTextLabel.text = messageViewData.messageText ?? "EMPTY"
        cell.dateLabel.text = messageViewData.dateUpdatedText ?? "NO DATE"
        cell.profImage.image = messageViewData.userPhoto
        
        return cell
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        
        header.titleLabel.text = messageViews[section].messageText ?? "EMPTY"
        header.arrowLabel.text = String(messageViews[section].children.count)
        header.setCollapsed(messageViews[section].isCollapsed)
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
}

//
// MARK: - Section Header Delegate
//
extension MessageTableViewController: CollapsibleTableViewHeaderDelegate {
    
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int) {
        let collapsed = !messageViews[section].isCollapsed
        
        // Toggle collapse
        messageViews[section].isCollapsed = collapsed
        header.setCollapsed(collapsed)
        
        self.tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
}
