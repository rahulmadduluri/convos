//
//  SearchTableViewController.swift
//  Convos
//
//  Created by Rahul Madduluri on 9/27/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

struct SearchViewData: CollapsibleTableViewData, Equatable {
    var photo: UIImage?
    var text: String
    var isTopLevel: Bool
    var isCollapsed: Bool
    var children: [CollapsibleTableViewData]
    
    init(conversation: Conversation) {
        self.photo = nil
        self.text = conversation
    }
    
    init(photo: UIImage?, text: String, isTopLevel: Bool = true, isCollapsed: Bool = true) {
        self.photo = photo
        self.text = text
        self.isTopLevel = isTopLevel
        self.isCollapsed = isCollapsed
        self.children = []
    }
}

func ==(lhs: SearchViewData, rhs: SearchViewData) -> Bool {
    return lhs.text == rhs.text
}

protocol SearchTableVCProtocol {
    func reloadSearchResultsData()
}

protocol SearchTableVCDelegate: CollapsibleTableVCDelegate {
    func filteredViewData() -> [SearchViewData]
}

class SearchTableViewController: CollapsibleTableViewController, SearchTableVCProtocol {
    
    var searchTableVCDelegate: SearchTableVCDelegate? = nil
    
    // MARK: - View Controller
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadSearchResultsData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        // Auto resizing the height of the cell
//        tableView.estimatedSectionHeaderHeight = 44.0
//        tableView.sectionHeaderHeight = 44.0
//        tableView.estimatedRowHeight = 44.0
//        tableView.rowHeight = 44.0
        // Other table view config
        tableView.separatorStyle = .none
    }
    
    // MARK: SearchTableVCProtocol
    
    func reloadSearchResultsData() {
        viewDataModels = searchTableVCDelegate?.filteredResults ?? []
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
    }
    
    // MARK: UIGestureRecognizer Functions
    
    override func cellTapped(row: Int, section: Int) {
        let viewData = viewDataModels[section].children[row]
        searchTableVCDelegate?.itemSelected(viewData: viewData)
    }
    
    override func headerTapped(section: Int) {
        let viewData = viewDataModels[section]
        searchTableVCDelegate?.itemSelected(viewData: viewData)
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
        
        if let searchViewData = viewDataModels[section] as? SearchViewData {
            header.customTextLabel.text = searchViewData.text
            header.photoImageView.image = searchViewData.photo
        }
                
        header.section = section
        header.delegate = self
                
        return header
    }
    
}
