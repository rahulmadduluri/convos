//
//  CollapsibleTableViewController.swift
//
//  Created by Yong Su on 5/30/16.
//  Copyright © 2016 Yong Su. All rights reserved.
//
//  Modified by Rahul Madduluri on 7/21/17.

import UIKit

protocol CollapsibleTableViewData {
    var photo: UIImage? { get set }
    var text: String { get }
    var isTopLevel: Bool { get }
    var isCollapsed: Bool { get set }
    var children: [CollapsibleTableViewData] { get set }
}

protocol CollapsibleTableVCDelegate {
    func itemSelected(viewData: CollapsibleTableViewData)
}

class CollapsibleTableViewController: UITableViewController {
    var viewDataModels: [CollapsibleTableViewData] = []
    var collapsibleTableVCDelegate: CollapsibleTableVCDelegate? = nil
}

//
// MARK: - View Controller DataSource and Delegate
//
extension CollapsibleTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewDataModels.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewDataModels[section].isCollapsed ? 0 : viewDataModels[section].children.count
    }

}

//
// MARK: - Section Header Delegate
//
extension CollapsibleTableViewController: CollapsibleTableViewHeaderDelegate, CollapsibleTableViewCellDelegate {
    
    func headerTapped(section: Int) {
        let collapsed = !viewDataModels[section].isCollapsed
        
        // Toggle collapse
        viewDataModels[section].isCollapsed = collapsed
        
        self.tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
    func cellTapped(row: Int, section: Int) {
    }
    
}
