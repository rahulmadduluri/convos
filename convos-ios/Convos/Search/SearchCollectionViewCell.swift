//
//  SearchCollectionViewCell.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/16/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell, SearchUIComponent {
    let customTextLabel = UILabel()
    let photoImageView = UIImageView()
    var row = 0
    
    var searchVC: SearchComponentDelegate?
    var type: SearchViewType?
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageHeight: CGFloat
        let imageWidth: CGFloat = self.bounds.width
        
        imageHeight = self.bounds.height * Constants.imageHeightRatioConversation
        
        photoImageView.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: imageWidth, height: imageHeight)
        self.addSubview(photoImageView)
        
        customTextLabel.frame = CGRect(x: self.bounds.minX, y: self.bounds.height * Constants.imageHeightRatioConversation, width: imageWidth, height: self.bounds.height * (1-Constants.imageHeightRatioConversation))
        customTextLabel.textAlignment = .center
        customTextLabel.font = customTextLabel.font.withSize(Constants.textFontSize)
        customTextLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(customTextLabel)
    }
    
}

private struct Constants {
    static let textFontSize: CGFloat = 12
    static let imageHeightRatioConversation: CGFloat = 0.75
}

