//
//  ContactsTableViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 3/7/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

private let cellReuseIdentifier = "ContactCell"

class ContactsTableViewController: UITableViewController, ContactsTableVCProtocol, ContactsUIComponent, UITextFieldDelegate {
    var contactsVC: ContactsComponentDelegate? = nil
    var cellHeightAtIndexPath = Dictionary<IndexPath, CGFloat>()
    var headerHeightAtSection = Dictionary<Int, CGFloat>()
    
    // MARK: - View Controller
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadContactsViewData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
    }
    
    // MARK: ContactsTableVCProtocol
    
    func reloadContactsViewData() {
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
    }
    
    // UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsVC?.getContactsViewData().count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell: MemberTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? MemberTableViewCell ??
            MemberTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        
        return max(cell.frame.size.height, Constants.cellHeight)
        
    }
}

// MARK: - UITableViewController

extension ContactsTableViewController {
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? ContactTableViewCell ??
            ContactTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        cell.contactsVC = contactsVC
        
        if let cvd = contactsVC?.getContactsViewData()[indexPath.row] {
            cell.customTextLabel.text = cvd.text
            if let uri = cvd.photoURI {
                cell.photoImageView.af_setImage(withURL: REST.imageURL(imageURI: uri))
            }
            cell.data = cvd
            switch cvd.status {
            case .contactExists:
                cell.statusButton.setImage(UIImage(named: "done"), for: .normal)
            case .contactNew:
                cell.statusButton.setImage(UIImage(named: "pending_user"), for: .normal)
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
