//
//  MemberTableViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

private let cellReuseIdentifier = "MemberCell"

class MemberTableViewController: UITableViewController, MemberTableVCProtocol, GroupInfoUIComponent {
    
    var groupInfoVC: GroupInfoComponentDelegate? = nil
    var cellHeightAtIndexPath = Dictionary<IndexPath, CGFloat>()
    var headerHeightAtSection = Dictionary<Int, CGFloat>()
    
    // MARK: - View Controller
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadMemberViewData()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupInfoVC?.getMemberViewData().count ?? 0
    }
        
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell: MemberTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? MemberTableViewCell ??
            MemberTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        
        return max(cell.frame.size.height, Constants.cellHeight)
        
    }

}

// MARK: - UITableViewController

extension MemberTableViewController {
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MemberTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? MemberTableViewCell ??
            MemberTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        cell.groupInfoVC = groupInfoVC
                
        if let mvd = groupInfoVC?.getMemberViewData()[indexPath.row] {
            cell.customTextLabel.text = mvd.text
            if let uri = mvd.photoURI {
                cell.photoImageView.af_setImage(withURL: REST.imageURL(imageURI: uri))
            }
            cell.data = mvd
            switch mvd.status {
            case .memberExists:
                cell.statusButton.setImage(UIImage(named: "done"), for: .normal)
            case .memberNew:
                cell.statusButton.setImage(UIImage(named: "pending_user"), for: .normal)
            case .memberRemovable:
                // don't show cancel next to this user
                if let myUUID = UserDefaults.standard.object(forKey: "uuid") as? String {
                    if myUUID != mvd.uuid {
                        cell.statusButton.setImage(UIImage(named: "cancel"), for: .normal)
                    }
                }
            default:
                break
            }
        }
        
        cell.row = indexPath.row
        
        return cell
    }
    
}

private struct Constants {
    static let cellHeight: CGFloat = 30
}
