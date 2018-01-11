//
//  SearchTableViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/27/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

private let cellReuseIdentifier = "SearchCell"

class SearchTableViewController: UITableViewController, SearchTableVCProtocol, SearchTableCellDelegate {
    
    var searchVC: SearchUIDelegate? = nil
    
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
    
    // MARK: SearchTableCellDelegate
    
    func cellTapped(uuid: String) {
        searchVC?.convoSelected(uuid: uuid)
    }
    
    func headerTapped(uuid: String) {
        searchVC?.groupSelected(uuid: uuid)
    }
}
    
//
// MARK: - Custom Cell & Header
//
extension SearchTableViewController {
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? SearchTableViewCell ??
            SearchTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        
        if let svd = searchVC?.getSearchViewData() {
            cell.searchViewData = svd[svd.keys[indexPath.section]]?[indexPath.row]
        }
        
        cell.row = indexPath.row
        cell.section = indexPath.section
        cell.delegate = self
                
        return cell
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: cellReuseIdentifier) as? SearchTableViewHeader ?? SearchTableViewHeader(reuseIdentifier: cellReuseIdentifier)
        
        if let svd = searchVC?.getSearchViewData() {
            header.searchViewData = svd[svd.keys[section]]
        }
        
        header.section = section
        header.delegate = self
                
        return header
    }
    
}
