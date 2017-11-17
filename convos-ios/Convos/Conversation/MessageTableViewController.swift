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
    var dateCreatedText: String
    
    init(photo: UIImage?, text: String, dateCreatedText: String, isTopLevel: Bool = true, isCollapsed: Bool = true) {
        self.photo = photo
        self.text = text
        self.dateCreatedText = dateCreatedText
        self.isTopLevel = isTopLevel
        self.isCollapsed = isCollapsed
        self.children = []
    }
}

func ==(lhs: MessageViewData, rhs: MessageViewData) -> Bool {
    return lhs.text == rhs.text && lhs.dateCreatedText == rhs.dateCreatedText
}

protocol MessageTableVCDelegate {
    func getViewData() -> [MessageViewData]
    func goBack()
}

protocol MessageTableVCProtocol {
    func resetMessageData()
    func addMessage(newMVD: MessageViewData, parentMVD: MessageViewData?)
}

class MessageTableViewController: CollapsibleTableViewController, MessageTableVCProtocol {
    
    var messageTableVCDelegate: MessageTableVCDelegate? = nil
    
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
        // Auto resizing the height of the cell
//        tableView.estimatedSectionHeaderHeight = 60.0
//        tableView.sectionHeaderHeight = 60.0
//        tableView.estimatedRowHeight = 44.0
//        tableView.rowHeight = 44.0
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
