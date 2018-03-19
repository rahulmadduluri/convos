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
    
    var scrolledToBottom: Bool = true
    var messageTableVCDelegate: MessageTableVCDelegate? = nil
    
    var cellHeightAtIndexPath = Dictionary<IndexPath, CGFloat>()
    var headerHeightAtSection = Dictionary<Int, CGFloat>()
    
    // MARK: - View Controller
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        
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
    
    func reloadMessageViewData() {
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
    }
        
    // UITableViewController
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return messageTableVCDelegate?.getMessageViewData().keys.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let mvd = messageTableVCDelegate?.getMessageViewData(),
            let children = mvd[mvd.keys[section]] {
            let k = mvd.keys[section]
            return k.isCollapsed ? 0 : children.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeightAtIndexPath[indexPath] ?? Constants.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return headerHeightAtSection[section] ?? Constants.headerHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell: MessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? MessageTableViewCell ??
            MessageTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        
        let height = max(cell.frame.size.height, Constants.rowHeight)
        cellHeightAtIndexPath[indexPath] = height
        return height
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier) as? MessageTableViewHeader ?? MessageTableViewHeader(reuseIdentifier: headerReuseIdentifier)
        
        let height = max(header.frame.size.height, Constants.headerHeight)
        headerHeightAtSection[section] = height
        return height
    }

    // MARK: MessageCellDelegate

    func messageTapped(section: Int, row: Int?) {
        var selectedMvd: MessageViewData
        guard var mvd = messageTableVCDelegate?.getMessageViewData() else {
            return
        }
        if row == nil {
            selectedMvd = mvd.keys[section]
            selectedMvd.isCollapsed = !selectedMvd.isCollapsed
            messageTableVCDelegate?.setMessageViewData(parent: nil, mvd: selectedMvd)
            tableView.reloadData()
        }
    }
    
}

//
// MARK: - Custom Cell & Header
//
extension MessageTableViewController {
    
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? MessageTableViewCell ?? MessageTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        
        if let messageViewData = messageTableVCDelegate?.findMessageViewData(primaryIndex: indexPath.section, secondaryIndex: indexPath.row) {
            cell.customTextLabel.text = messageViewData.text
            if let uri = messageViewData.photoURI {
                cell.photoImageView.af_setImage(withURL: REST.imageURL(imageURI: uri))
            }
        }
        
        cell.row = indexPath.row
        cell.section = indexPath.section
        cell.delegate = self
        
        return cell
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier) as? MessageTableViewHeader ?? MessageTableViewHeader(reuseIdentifier: headerReuseIdentifier)
        
        if let messageViewData = messageTableVCDelegate?.findMessageViewData(primaryIndex: section, secondaryIndex: nil) {
            header.customTextLabel.text = messageViewData.text
            if let uri = messageViewData.photoURI {
                header.photoImageView.af_setImage(withURL: REST.imageURL(imageURI: uri))
            }
        }
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
}

private struct Constants {
    static let headerHeight: CGFloat = 30.0
    static let rowHeight: CGFloat = 30.0
}

