//
//  CollapsibleTableViewController.swift
//
//  Created by Yong Su on 5/30/16.
//  Copyright © 2016 Yong Su. All rights reserved.
//
//  Modified by Rahul Madduluri on 7/21/17.

import UIKit

class CollapsibleTableViewCell: UITableViewCell {
    
    let messageTextLabel = UILabel()
    let dateLabel = UILabel()
    let separator = UIView()
    let profImage = UIImageView()
    
    // MARK: Initalizers
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let marginGuide = contentView.layoutMarginsGuide
        
        // configure separator
        contentView.addSubview(separator)
        separator.backgroundColor = UIColor.blue
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        separator.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.separatorWidth).isActive = true
        separator.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        
        // configure image view
        contentView.addSubview(profImage)
        profImage.backgroundColor = UIColor.white
        profImage.layer.cornerRadius = 5.0
        profImage.layer.masksToBounds = true
        profImage.translatesAutoresizingMaskIntoConstraints = false
        profImage.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        profImage.leadingAnchor.constraint(equalTo: separator.trailingAnchor, constant: Constants.leadingImageAnchorConstant).isActive = true
        profImage.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.imageWidth).isActive = true
        profImage.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.imageHeight).isActive = true
        
        // configure message text label
        contentView.addSubview(messageTextLabel)
        messageTextLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTextLabel.leadingAnchor.constraint(equalTo: profImage.trailingAnchor, constant: Constants.leadingMessageAnchorConstant).isActive = true
        messageTextLabel.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        messageTextLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        messageTextLabel.numberOfLines = 0
        messageTextLabel.font = UIFont.systemFont(ofSize: Constants.messageTextFontSize)
        
        // configure date label
        contentView.addSubview(dateLabel)
        dateLabel.lineBreakMode = .byWordWrapping
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        dateLabel.topAnchor.constraint(equalTo: messageTextLabel.bottomAnchor, constant: Constants.messageTextDateTextGap).isActive = true
        dateLabel.numberOfLines = 0
        dateLabel.font = UIFont.systemFont(ofSize: Constants.dateTextFontSize)
        dateLabel.textColor = UIColor.black
        
        // cell config
        self.selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct Constants {
    static let messageTextFontSize: CGFloat = 16
    static let dateTextFontSize: CGFloat = 10
    static let leadingImageAnchorConstant: CGFloat = 20
    static let leadingMessageAnchorConstant: CGFloat = 20
    static let messageTextDateTextGap: CGFloat = 5
    static let separatorWidth: CGFloat = 3
    static let imageWidth: CGFloat = 30
    static let imageHeight: CGFloat = 30
}
