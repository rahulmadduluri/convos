//
//  SearchTableViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/27/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

private let cellReuseIdentifier = "SearchCell"
private let headerReuseIdentifier = "SearchHeader"

class SearchTableViewController: UITableViewController, SearchTableVCProtocol {
    
    var searchVC: SearchComponentDelegate? = nil
    var cellHeightAtIndexPath = Dictionary<IndexPath, CGFloat>()
    var headerHeightAtSection = Dictionary<Int, CGFloat>()
    
    // MARK: - View Controller
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadSearchViewData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
    }
    
    // MARK: SearchTableVCProtocol
    
    func reloadSearchViewData() {
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
    }
    
    // UITableViewController
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return searchVC?.getSearchViewData().keys.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell: MessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? MessageTableViewCell ??
            MessageTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        
        let height = max(cell.frame.size.height, 80.0)
        cellHeightAtIndexPath[indexPath] = height
        return height
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier) as? MessageTableViewHeader ?? MessageTableViewHeader(reuseIdentifier: headerReuseIdentifier)
        
        let height = max(header.frame.size.height, 40.0)
        headerHeightAtSection[section] = height
        return height
    }
    
}

// MARK: - UITableViewController

extension SearchTableViewController {
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? SearchTableViewCell ??
            SearchTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        
        /*
        if let svd = searchVC?.getSearchViewData() {
        }
 */
        
        cell.row = indexPath.row
        cell.section = indexPath.section
        cell.delegate = self.searchVC as? SearchTableComponentDelegate
                
        return cell
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: cellReuseIdentifier) as? SearchTableViewHeader ?? SearchTableViewHeader(reuseIdentifier: cellReuseIdentifier)
        
        if let svd = searchVC?.getSearchViewData().keys[section] {
            header.customTextLabel.text = svd.text
            header.photoImageView.image = svd.photo
        }
        
        header.section = section
        header.delegate = self.searchVC as? SearchTableComponentDelegate
                
        return header
    }
    
}
