//
//  MessageTableViewController.swift
//
//  Created by Rahul Madduluri on 9/21/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit


class MessageTableViewController: UITableViewController, MessageTableVCProtocol, MessageTableCellDelegate {
    
    var messageTableVCDelegate: MessageTableVCDelegate? = nil
    
    var cellHeightAtIndexPath = Dictionary<IndexPath, CGFloat>()
    var headerHeightAtSection = Dictionary<Int, CGFloat>()
    
    // MARK: - View Controller
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add test messages
        let testMessage = MessageViewData(photo: UIImage(named: "rahul_test_pic"), text: "yoyoyoyoyoyoyoyoyo", dateCreatedText: "9/8/17")
        let testMessage2 = MessageViewData(photo: UIImage(named: "rahul_test_pic"), text: "My Name is Jo", dateCreatedText: "9/8/18")
        let testMessage3 = MessageViewData(photo: UIImage(named: "rahul_test_pic"), text: "I have a big fro", dateCreatedText: "9/8/19")
        let testMessage4 = MessageViewData(photo: UIImage(named: "praful_test_pic"), text: "testtest", dateCreatedText: "9/8/20")
        let testMessage5 = MessageViewData(photo: UIImage(named: "praful_test_pic"), text: "teststststststststststets", dateCreatedText: "9/9/20")
        addMessage(newMVD: testMessage, parentMVD: nil)
        addMessage(newMVD: testMessage2, parentMVD: nil)
        addMessage(newMVD: testMessage3, parentMVD: testMessage2)
        addMessage(newMVD: testMessage4, parentMVD: testMessage2)
        addMessage(newMVD: testMessage5, parentMVD: testMessage2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
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
    
    func resetMessageData() {
        if let vd = messageTableVCDelegate?.getViewData() {
            viewDataModels = vd
        }
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
    }
    
    func addMessage(newMVD: MessageViewData, parentMVD: MessageViewData?) {
        var foundParent = false
        if let parentMVD = parentMVD {
            for index in 0...viewDataModels.count-1 {
                guard let dm = viewDataModels[index] as? MessageViewData else {
                    continue
                }
                if dm == parentMVD {
                    viewDataModels[index].children.append(newMVD)
                    foundParent = true
                }
            }
        }
        
        if !foundParent {
            viewDataModels.append(newMVD)
        }
        tableView.reloadData()
    }
    
    // UITableViewController
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return delegate?.viewDataModels.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let vdm = viewDataModels[section] as? CollapsibleTableViewData {
            return vdm.isCollapsed ? 0 : vdm.children.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeightAtIndexPath[indexPath] ?? 40.0
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return headerHeightAtSection[section] ?? 40.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell: CollapsibleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CollapsibleTableViewCell ??
            CollapsibleTableViewCell(style: .default, reuseIdentifier: "cell")
        
        let height = max(cell.frame.size.height, 40.0)
        cellHeightAtIndexPath[indexPath] = height
        return height
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "messageHeader") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "messageHeader")
        
        let height = max(header.frame.size.height, 40.0)
        headerHeightAtSection[section] = height
        return height
    }
    
    // MARK: MessageCellDelegate

    func messageTapped(section: Int, row: Int?, mvd: MessageViewData) {
        guard let delegate = messageTableVCDelegate else {
            return
        }
        if row == nil {
            if (delegate.getViewData())
        }
        if let d = messageTableVCDelegate,
            let hasMessage:
        self.tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .none)
    }
    
}

//
// MARK: - Custom Cell & Header
//
extension MessageTableViewController {
    
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as? MessageTableViewCell ??
            MessageTableViewCell(style: .default, reuseIdentifier: "messageCell")
        
        if let messageViewData = viewDataModels[indexPath.section].children[indexPath.row] as? MessageViewData {
            cell.customTextLabel.text = messageViewData.text
            cell.photoImageView.image = messageViewData.photo
        }
        
        cell.row = indexPath.row
        cell.section = indexPath.section
        cell.delegate = self
        
        return cell
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ConversationTableViewHeader ?? ConversationTableViewHeader(reuseIdentifier: "header")
        
        if let messageViewData = viewDataModels[section] as? MessageViewData {
            header.customTextLabel.text = messageViewData.text
            header.rightSideLabel.text = String(messageViewData.children.count)
            header.photoImageView.image = messageViewData.photo
        }
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
}
