//
//  GroupMemberTableViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

private let cellReuseIdentifier = "MemberCell"

class GroupMemberTableViewController: UITableViewController, GroupMemberTableVCProtocol {
    
    var cellHeightAtIndexPath = Dictionary<IndexPath, CGFloat>()
    var headerHeightAtSection = Dictionary<Int, CGFloat>()
    
    // MARK: - View Controller
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // MAYBE SHOULD REMOVE FROM SEARCH reloadMemberViewData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
    }
    
    // MARK: SearchTableVCProtocol
    
    func reloadMemberViewData() {
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
    }
    
    // UITableViewController
        
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell: GroupMemberTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? GroupMemberTableViewCell ??
            GroupMemberTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        
        return max(cell.frame.size.height, 30.0)
        
    }

}

// MARK: - UITableViewController

extension GroupMemberTableViewController {
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GroupMemberTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? GroupMemberTableViewCell ??
            GroupMemberTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        
        cell.row = indexPath.row
        
        return cell
    }
    
}
