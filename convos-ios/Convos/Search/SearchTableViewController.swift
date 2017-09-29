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
    func loadSearchResultsData(searchData: [SearchViewData])
    func resetSearchResultsData()
}

protocol SearchTableVCDelegate: CollapsibleTableVCDelegate, SearchComponentDelegate {
}

class SearchTableViewController: CollapsibleTableViewController, SearchTableVCProtocol {
    
    var searchTableVCDelegate: SearchTableVCDelegate? = nil
    
    // MARK: - View Controller
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add test messages
        let res1 = SearchViewData(photo: UIImage(named: "rahul_test_pic"), text: "Rahul")
        let res2 = SearchViewData(photo: UIImage(named: "praful_test_pic"), text: "Praful")
        let res3 = SearchViewData(photo: UIImage(named: "reia_test_pic"), text: "Reia")
        loadSearchResultsData(searchData: [res1,res2,res3])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        // Auto resizing the height of the cell
        tableView.estimatedSectionHeaderHeight = 44.0
        tableView.sectionHeaderHeight = 44.0
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        // Other table view config
        tableView.separatorStyle = .none
    }
    
    // MARK: SearchTableVCProtocol
    
    func loadSearchResultsData(searchData: [SearchViewData]) {
        viewDataModels = searchData
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
    }
    
    func resetSearchResultsData() {
        viewDataModels = []
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
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
            cell.photoImageView.image = searchViewData.photo
        }
        
        return cell
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SearchTableViewHeader ?? SearchTableViewHeader(reuseIdentifier: "header")
        
        if let searchViewData = viewDataModels[section] as? SearchViewData {
            header.customTextLabel.text = searchViewData.text
            header.rightSideLabel.text = String(searchViewData.children.count)
        }
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
}
