//
//  CollapsibleTableViewController.swift
//
//  Created by Yong Su on 5/30/16.
//  Copyright © 2016 Yong Su. All rights reserved.
//
//  Modified by Rahul Madduluri on 7/21/17.

import UIKit

// MARK: - View Controller DataSource and Delegate
//
extension CollapsibleTableViewController {
    
    
}

//
// MARK: - Section Header Delegate
//
extension CollapsibleTableViewController: CollapsibleTableViewHeaderDelegate, CollapsibleTableViewCellDelegate {
    
    func headerTapped(section: Int) {
        if var vdm = viewDataModels[section] as? CollapsibleTableViewData {
            let collapsed = !vdm.isCollapsed
            
            // Toggle collapse
            vdm.isCollapsed = collapsed
            
            self.tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .none)
        }
    }
    
    func cellTapped(row: Int, section: Int) {
    }
    
}
