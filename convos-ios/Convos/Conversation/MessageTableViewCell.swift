//
//  MessageTableViewCell.swift
//
//  Created by Rahul Madduluri on 7/21/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit


class MessageTableViewCell: UITableViewCell, MessageUIComponent {
    
    var delegate: MessageTableCellDelegate?

    let customTextLabel = UILabel()
    let photoImageView = UIImageView()
    let separator = UIView()
    
    var section = 0
    var row = 0
    
    var messageViewData: MessageViewData? {
        get {
            return self.messageViewData
        }
        set {
            self.messageViewData = newValue
            customTextLabel.text = messageViewData?.text
            photoImageView.image = messageViewData?.photo
        }
    }
    
    // MARK: Initalizers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let marginGuide = contentView.layoutMarginsGuide
                
        // configure separator
        contentView.addSubview(separator)
        separator.backgroundColor = UIColor.blue
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor, constant: Constants.leadingSeparatorAnchorConstant).isActive = true
        separator.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.separatorWidth).isActive = true
        separator.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        
        // configure image view
        contentView.addSubview(photoImageView)
        photoImageView.backgroundColor = UIColor.white
        photoImageView.layer.cornerRadius = 12.0
        photoImageView.layer.masksToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
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
        customTextLabel.font = UIFont.systemFont(ofSize: Constants.messageTextFontSize)
                
        // cell config
        self.selectionStyle = .none
        
        // Gesture Recognizer
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MessageTableViewCell.tapCell(_:))))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // Gesture Recognizer
    
    func tapCell(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? MessageTableViewCell else {
            return
        }
        
        delegate?.messageTapped(section: cell.section, mvd: cell.messageViewData)
    }
    
}

private struct Constants {
    static let leadingSeparatorAnchorConstant: CGFloat = 30
    static let messageTextFontSize: CGFloat = 16
    static let leadingImageAnchorConstant: CGFloat = 20
    static let leadingMessageAnchorConstant: CGFloat = 20
    static let messageTextDateTextGap: CGFloat = 5
    static let separatorWidth: CGFloat = 2
    static let imageWidth: CGFloat = 24
    static let imageHeight: CGFloat = 24
}
