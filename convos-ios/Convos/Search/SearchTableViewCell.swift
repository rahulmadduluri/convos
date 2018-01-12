//
//  SearchTableViewCell.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/10/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    var section = 0
    var row = 0
    var delegate: SearchTableCellDelegate?
    
    var searchViewData: [SearchViewData]? {
        get {
            return self.searchViewData
        }
        set {
            self.searchViewData = newValue
        }
    }

    // MARK: Initalizers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //let marginGuide = contentView.layoutMarginsGuide
        
        // cell config
        self.selectionStyle = .none

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private struct Constants {
}
