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
    
    var cellHeightAtIndexPath = Dictionary<IndexPath, CGFloat>()
    var headerHeightAtSection = Dictionary<Int, CGFloat>()
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
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeightAtIndexPath[indexPath] ?? 40.0
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return headerHeightAtSection[section] ?? 40.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell: CollapsibleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CollapsibleTableViewCell ??
            CollapsibleTableViewCell(style: .default, reuseIdentifier: "cell")

        let height = max(cell.frame.size.height, 40.0)
        cellHeightAtIndexPath[indexPath] = height
        return height

    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        
        let height = max(header.frame.size.height, 40.0)
        headerHeightAtSection[section] = height
        return height
    }
    
    
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let height = view.frame.size.height
//        headerHeightAtSection[section] = height
//    }
//    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let height = cell.frame.size.height
//        cellHeightAtIndexPath[indexPath] = height
//    }

}

//
// MARK: - Section Header Delegate
//
extension CollapsibleTableViewController: CollapsibleTableViewHeaderDelegate, CollapsibleTableViewCellDelegate {
    
    func headerTapped(section: Int) {
        let collapsed = !viewDataModels[section].isCollapsed
        
        // Toggle collapse
        viewDataModels[section].isCollapsed = collapsed
        
        self.tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .none)
    }
    
    func cellTapped(row: Int, section: Int) {
    }
    
}
