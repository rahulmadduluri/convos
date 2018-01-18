//
//  SearchCollectionViewCell.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/16/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: CustomCollectionViewCell, SearchUIComponent {
    var delegate: SearchTableComponentDelegate?
    var type: SearchViewType?
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = UIColor.green
        
        self.photoImageView.frame = self.bounds
        self.addSubview(photoImageView)
    }
}
