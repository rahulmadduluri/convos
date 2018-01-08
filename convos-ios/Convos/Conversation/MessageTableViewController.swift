//
//  MessageTableViewController.swift
//
//  Created by Rahul Madduluri on 9/21/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

private let headerReuseIdentifier = "MessageHeader"
private let cellReuseIdentifier = "MessageCell"

class MessageTableViewController: UITableViewController, MessageTableVCProtocol, MessageTableCellDelegate {
    
    var messageTableVCDelegate: MessageTableVCDelegate? = nil
    
    var cellHeightAtIndexPath = Dictionary<IndexPath, CGFloat>()
    var headerHeightAtSection = Dictionary<Int, CGFloat>()
    
    // MARK: - View Controller
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add test messages
        let testMessage = MessageViewData(uuid: "1", photo: UIImage(named: "rahul_test_pic"), text: "yoyoyoyoyoyoyoyoyo", createdTimestamp: 0, createdTimeText: "9/8/17")
        let testMessage2 = MessageViewData(uuid: "2", photo: UIImage(named: "rahul_test_pic"), text: "My Name is Jo", createdTimestamp: 1, createdTimeText: "9/8/18")
        let testMessage3 = MessageViewData(photo: UIImage(named: "rahul_test_pic"), text: "I have a big fro", createdTimestamp: 2, createdTimeText: "9/8/19")
        let testMessage4 = MessageViewData(photo: UIImage(named: "praful_test_pic"), text: "testtest", createdTimestamp: 3, createdTimeText: "9/8/20")
        let testMessage5 = MessageViewData(photo: UIImage(named: "praful_test_pic"), text: "teststststststststststets", createdTimestamp: 4, createdTimeText: "9/9/20")
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
        let cell: CollapsibleTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? CollapsibleTableViewCell ??
            CollapsibleTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        
        let height = max(cell.frame.size.height, 40.0)
        cellHeightAtIndexPath[indexPath] = height
        return height
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier) as? MessageTableViewHeader ?? MessageTableViewHeader(reuseIdentifier: headerReuseIdentifier)
        
        let height = max(header.frame.size.height, 40.0)
        headerHeightAtSection[section] = height
        return height
    }
    
    // MARK: MessageCellDelegate

    func messageTapped(section: Int, row: Int?, mvd: MessageViewData?) {
        guard let delegate = messageTableVCDelegate,
            let actualMVD = mvd else {
            return
        }
        // if header, not row
        if row == nil {
            if var m = delegate.messageViewData.keys.filter({ $0 == actualMVD }).first {
                m.isCollapsed = !m.isCollapsed
                self.tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .none)
            }
        }
    }
    
}

//
// MARK: - Custom Cell & Header
//
extension MessageTableViewController {
    
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MessageTableViewCell
        
        if let messageViewData = viewDataModels[indexPath.section].children[indexPath.row] as? MessageViewData {
            cell.messageViewData = messageViewData
        }
        
        cell.row = indexPath.row
        cell.section = indexPath.section
        cell.delegate = self
        
        return cell
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier) as? ConversationTableViewHeader ?? ConversationTableViewHeader(reuseIdentifier: headerReuseIdentifier)
        
        // should be Key that matches search -- if let messageViewData = viewDataModels[section] as? MessageViewData {
            header.messageViewData = messageViewData
            header.rightSideLabel.text = String(viewDataModes[section].count)
        }
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
}
