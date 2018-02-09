//
//  SearchCollectionViewCell.swift
//  Convos
//
//  Created by Rahul Madduluri on 1/16/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: CustomCollectionViewCell, SearchUIComponent {
    var searchVC: SearchComponentDelegate?
    var type: SearchViewType?
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.backgroundColor = UIColor.green
        
        let imageHeight: CGFloat
        let imageWidth: CGFloat = self.bounds.width
        if type == .conversation {
            imageHeight = self.bounds.height * Constants.imageHeightRatioConversation
        }else {
            imageHeight = self.bounds.height
        }
        
        photoImageView.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: imageWidth, height: imageHeight)
        photoImageView.backgroundColor = UIColor.cyan
        self.addSubview(photoImageView)
        
        customTextLabel.frame = CGRect(x: self.bounds.minX, y: self.bounds.height * Constants.imageHeightRatioConversation, width: imageWidth, height: self.bounds.height * (1-Constants.imageHeightRatioConversation))
        customTextLabel.textAlignment = .center
        customTextLabel.font = customTextLabel.font.withSize(Constants.textFontSize)
        customTextLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(customTextLabel)
    }
    
}

private struct Constants {
    static let textFontSize: CGFloat = 17
    static let imageHeightRatioConversation: CGFloat = 0.75
}

