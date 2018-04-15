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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell: SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? SearchTableViewCell ??
            SearchTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        
        return max(cell.frame.size.height, 80.0)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier) as? SearchTableViewHeader ?? SearchTableViewHeader(reuseIdentifier: headerReuseIdentifier)
        
        return max(header.frame.size.height, 40.0)
    }
    
}

// MARK: - UITableViewController

extension SearchTableViewController {
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? SearchTableViewCell ??
            SearchTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        
        cell.row = indexPath.row
        cell.section = indexPath.section
        cell.searchVC = searchVC
        cell.refreshCollectionView(tag: indexPath.section)
        
        return cell
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier) as? SearchTableViewHeader ?? SearchTableViewHeader(reuseIdentifier: headerReuseIdentifier)
        
        if let svd = searchVC?.getSearchViewData().keys[section] {
            header.customTextLabel.text = svd.text
            if let uri = svd.photoURI {
                var urlRequest = URLRequest(url: REST.imageURL(imageURI: uri))
                urlRequest.setValue(APIHeaders.authorizationValue(), forHTTPHeaderField: "Authorization")
                header.photoImageView.af_setImage(withURLRequest: urlRequest)
            }
        }
        
        header.section = section
        header.searchVC = self.searchVC
                
        return header
    }
    
}
