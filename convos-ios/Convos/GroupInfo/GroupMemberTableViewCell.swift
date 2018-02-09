//
//  GroupMemberCell.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class GroupMemberTableViewCell: UITableViewCell {
    
    let customTextLabel = UILabel()
    let photoImageView = UIImageView()
    private let separator = UIView()
    
    var row = 0
    
    // MARK: Initalizers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let marginGuide = contentView.layoutMarginsGuide
        
        // configure separator
        contentView.addSubview(separator)
        separator.backgroundColor = UIColor.blue
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leadingSeparatorAnchorConstant).isActive = true
        separator.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.separatorWidth).isActive = true
        separator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topSeparatorAnchorConstant).isActive = true
        separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Constants.bottomSeparatorAnchorConstant).isActive = true
        
        // configure image view
        contentView.addSubview(photoImageView)
        photoImageView.backgroundColor = UIColor.white
        photoImageView.layer.cornerRadius = Constants.imageCornerRadius
        photoImageView.layer.masksToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        photoImageView.leadingAnchor.constraint(equalTo: separator.trailingAnchor, constant: Constants.leadingImageAnchorConstant).isActive = true
        photoImageView.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.imageWidth).isActive = true
        photoImageView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.imageHeight).isActive = true
        
        // configure message text label
        contentView.addSubview(customTextLabel)
        customTextLabel.translatesAutoresizingMaskIntoConstraints = false
        customTextLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: Constants.leadingMessageAnchorConstant).isActive = true
        customTextLabel.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        customTextLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        customTextLabel.numberOfLines = 0
        customTextLabel.font = customTextLabel.font.withSize(Constants.textFontSize)
        customTextLabel.adjustsFontSizeToFitWidth = true
        
        // cell config
        self.selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

private struct Constants {
    static let leadingSeparatorAnchorConstant: CGFloat = 0
    static let topSeparatorAnchorConstant: CGFloat = 0
    static let bottomSeparatorAnchorConstant: CGFloat = 0
    static let textFontSize: CGFloat = 16
    static let leadingImageAnchorConstant: CGFloat = -13
    static let leadingMessageAnchorConstant: CGFloat = 20
    static let separatorWidth: CGFloat = 2
    static let imageWidth: CGFloat = 24
    static let imageHeight: CGFloat = 24
    static let imageCornerRadius: CGFloat = 12
}
