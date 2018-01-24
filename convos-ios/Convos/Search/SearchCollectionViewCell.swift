//
//  SearchCollectionViewCell.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/16/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: CustomCollectionViewCell, SearchUIComponent {
    var searchVC: SearchTableComponentDelegate?
    var type: SearchViewType?
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = UIColor.green
        
        let imageHeight: CGFloat
        let imageWidth: CGFloat = self.bounds.width
        if type == .conversation {
            imageHeight = self.bounds.height * 0.75
        }else {
            imageHeight = self.bounds.height
        }
        
        photoImageView.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: imageWidth, height: imageHeight)
        photoImageView.backgroundColor = UIColor.cyan
        self.addSubview(photoImageView)
        
        customTextLabel.frame = CGRect(x: self.bounds.minX, y: self.bounds.height * 0.75, width: imageWidth, height: self.bounds.height * 0.25)
        customTextLabel.textAlignment = .center
        self.addSubview(customTextLabel)
    }
    
}
