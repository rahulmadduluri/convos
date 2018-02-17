//
//  MemberCell.swift
//  Convos
//
//  Created by Rahul Madduluri on 2/9/18.
//  Copyright © 2018 rahulm. All rights reserved.
//

import UIKit

class MemberTableViewCell: UITableViewCell {
    
    var data: MemberViewData?
    let customTextLabel = UILabel()
    let photoImageView = UIImageView()
    let statusButton = UIButton()
    private let separator = UIView()

    var groupInfoVC: GroupInfoComponentDelegate?
    var row = 0
    
    // MARK: Initalizers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let marginGuide = contentView.layoutMarginsGuide
                
        // configure separator
        contentView.addSubview(separator)
        separator.backgroundColor = UIColor.blue
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leadingSeparatorAnchor).isActive = true
        separator.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.separatorWidth).isActive = true
        separator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topSeparatorAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Constants.bottomSeparatorAnchor).isActive = true
        
        // configure image view
        contentView.addSubview(photoImageView)
        photoImageView.backgroundColor = UIColor.white
        photoImageView.layer.cornerRadius = Constants.imageCornerRadius
        photoImageView.layer.masksToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        photoImageView.leadingAnchor.constraint(equalTo: separator.trailingAnchor, constant: Constants.leadingImageAnchor).isActive = true
        photoImageView.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.imageRadius).isActive = true
        photoImageView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.imageRadius).isActive = true
        
        // configure message text label
        contentView.addSubview(customTextLabel)
        customTextLabel.translatesAutoresizingMaskIntoConstraints = false
        customTextLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: Constants.leadingMessageAnchor).isActive = true
        customTextLabel.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        customTextLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        customTextLabel.numberOfLines = 0
        customTextLabel.font = customTextLabel.font.withSize(Constants.textFontSize)
        customTextLabel.adjustsFontSizeToFitWidth = true
        
        // configure status image view
        contentView.addSubview(statusButton)
        statusButton.layer.masksToBounds = true
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        statusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        statusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.trailingStatusImageAnchor).isActive = true
        statusButton.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.statusImageRadius).isActive = true
        statusButton.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.statusImageRadius).isActive = true
        statusButton.addTarget(self, action: #selector(MemberTableViewCell.tapStatus(_:)), for: .touchUpInside)
        
        // cell config
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapStatus(_ gestureRecognizer: UITapGestureRecognizer) {
        if let d = data {
            groupInfoVC?.memberStatusSelected(mvd: d)
        }
    }
}

private struct Constants {
    static let leadingSeparatorAnchor: CGFloat = 0
    static let topSeparatorAnchor: CGFloat = 0
    static let bottomSeparatorAnchor: CGFloat = 0
    static let separatorWidth: CGFloat = 2
    
    static let leadingMessageAnchor: CGFloat = 20
    static let textFontSize: CGFloat = 16
    
    static let leadingImageAnchor: CGFloat = 20
    static let imageRadius: CGFloat = 24
    static let imageCornerRadius: CGFloat = 12
    
    static let statusImageRadius: CGFloat = 28
    static let trailingStatusImageAnchor: CGFloat = -30
}
