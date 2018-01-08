//
//  CollapsibleTableViewController.swift
//
//  Created by Yong Su on 5/30/16.
//  Copyright © 2016 Yong Su. All rights reserved.
//

import UIKit


class CollapsibleTableViewCell: UITableViewCell {
    
    var delegate: CollapsibleTableViewCellDelegate?
    let customTextLabel = UILabel()
    let photoImageView = UIImageView()
    
    var section = 0
    var row = 0
    
    // MARK: Initalizers
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //
        // Call tapCell when tapping on this header
        //
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CollapsibleTableViewCell.tapCell(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // Override by subclass
    //
    func tapCell(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CollapsibleTableViewCell else {
            return
        }
        
        delegate?.cellTapped(row: cell.row, section: cell.section)
    }
    
}
