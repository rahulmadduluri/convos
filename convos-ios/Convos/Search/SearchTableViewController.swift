//
//  SearchTableViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/27/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, SearchTableVCProtocol {
    
    var searchVC: SearchUIDelegate? = nil
    
    // MARK: - View Controller
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadSearchResultsData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
    }
    
    // MARK: SearchTableVCProtocol
    
    func reloadSearchResultsData() {
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
    }
    
    // MARK: Cell/Header Delegate Functions
    
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
        let cell: SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as? SearchTableViewCell ??
            SearchTableViewCell(style: .default, reuseIdentifier: "cell")
        
        if let searchViewData = viewDataModels[indexPath.section].children[indexPath.row] as? SearchViewData {
            cell.customTextLabel.text = searchViewData.text
        }
        
        cell.row = indexPath.row
        cell.section = indexPath.section
        cell.delegate = self
                
        return cell
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SearchTableViewHeader ?? SearchTableViewHeader(reuseIdentifier: "header")
        
        if let svc = searchVC,
            let searchViewData = svc.searchViewData.keys as? SearchViewData {
            header.customTextLabel.text = searchViewData.text
            header.photoImageView.image = searchViewData.photo
        }
                
        header.section = section
        header.delegate = self
                
        return header
    }
    
}
