//
//  SearchTableViewHeader.swift
//
//  Created by Rahul Madduluri on 7/21/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class SearchTableViewHeader: CollapsibleTableViewHeader {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Content View
        contentView.backgroundColor = UIColor.white
        
        let marginGuide = contentView.layoutMarginsGuide
        
        // Title label
        contentView.addSubview(customTextLabel)
        customTextLabel.textColor = UIColor.black
        customTextLabel.translatesAutoresizingMaskIntoConstraints = false
        customTextLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        customTextLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        customTextLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        customTextLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
