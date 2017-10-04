//
//  SearchTableViewCell.swift
//
//  Created by Rahul Madduluri on 7/21/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class SearchTableViewCell: CollapsibleTableViewCell {
    
    let separator = UIView()
    
    // MARK: Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let marginGuide = contentView.layoutMarginsGuide
        
        // configure separator
        contentView.addSubview(separator)
        separator.backgroundColor = UIColor.blue
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor, constant: Constants.separatorLeadingAnchor).isActive = true
        separator.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.separatorWidth).isActive = true
        separator.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        
        // configure text label
        contentView.addSubview(customTextLabel)
        customTextLabel.translatesAutoresizingMaskIntoConstraints = false
        customTextLabel.leadingAnchor.constraint(equalTo: separator.trailingAnchor, constant: Constants.leadingTextAnchorConstant).isActive = true
        customTextLabel.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        customTextLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        customTextLabel.numberOfLines = 0
        customTextLabel.font = UIFont.systemFont(ofSize: Constants.textFontSize)
                
        // cell config
        self.selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private struct Constants {
    static let textFontSize: CGFloat = 16
    static let leadingTextAnchorConstant: CGFloat = 20
    static let separatorWidth: CGFloat = 2
    static let separatorLeadingAnchor: CGFloat = 10
}
