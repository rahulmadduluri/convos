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

//
// MARK: - View Controller
//
class MessageTableViewController: UITableViewController, MessageTableVCProtocol {
    
    var messageViews: [MessageViewData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Auto resizing the height of the cell
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.title = "Apple Products"
    }
    
    // MARK: MessageTableVCProtocol
    
    func loadMessageData(messageData: [MessageViewData]) {
        messageViews = messageData
    }
    
    func addMessage(newMessage: MessageViewData, parentMessage: MessageViewData?) {
        var foundParent = false
        if let parent = parentMessage {
            for var message in messageViews {
                if message == parent {
                    message.children.append(newMessage)
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
        
        cell.nameLabel.text = messageViewData.messageText ?? "message text is nil"
        cell.detailLabel.text = messageViewData.dateUpdatedText ?? "date updated text is nil"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        
        header.titleLabel.text = messageViews[section].messageText ?? "message text is nil"
        header.arrowLabel.text = messageViews[section].children.count > 0 ? String(messageViews[section].children.count) : ""
        header.setCollapsed(messageViews[section].isCollapsed)
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
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
        
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
}
