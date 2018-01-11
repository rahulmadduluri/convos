//
//  ConversationTableViewHeader.swift
//
//  Created by Rahul Madduluri on 7/21/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit

class MessageTableViewHeader: UITableViewHeaderFooterView, MessageUIComponent {
    
    var delegate: MessageTableCellDelegate?
    let customTextLabel = UILabel()
    let rightSideLabel = UILabel()
    let photoImageView = UIImageView()
    
    var section: Int = 0
    
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
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Content View
        contentView.backgroundColor = UIColor.white
        
        let marginGuide = contentView.layoutMarginsGuide
                
        // configure image view
        contentView.addSubview(photoImageView)
        photoImageView.layer.cornerRadius = 15.0
        photoImageView.layer.masksToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        photoImageView.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor, constant: Constants.leadingImageAnchorConstant).isActive = true
        photoImageView.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.imageWidth).isActive = true
        photoImageView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.imageHeight).isActive = true
        
        // Title label
        contentView.addSubview(customTextLabel)
        customTextLabel.translatesAutoresizingMaskIntoConstraints = false
        customTextLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: Constants.leadingTextAnchorConstant).isActive = true
        customTextLabel.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        customTextLabel.numberOfLines = 0
        customTextLabel.font = UIFont.systemFont(ofSize: Constants.textFontSize)
        
        // Arrow label
        contentView.addSubview(rightSideLabel)
        rightSideLabel.textColor = UIColor.black
        rightSideLabel.translatesAutoresizingMaskIntoConstraints = false
        rightSideLabel.widthAnchor.constraint(equalToConstant: 12).isActive = true
        rightSideLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        rightSideLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        rightSideLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        
        // UIGestureRecognizer
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MessageTableViewHeader.tapHeader(_:))))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // Trigger toggle section when tapping on the header
    //
    func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? MessageTableViewHeader else {
            return
        }
        
        delegate?.messageTapped(section: cell.section, mvd: messageViewData)
    }

}

private struct Constants {
    static let textFontSize: CGFloat = 16
    static let leadingImageAnchorConstant: CGFloat = 20
    static let leadingTextAnchorConstant: CGFloat = 20
    static let imageWidth: CGFloat = 30
    static let imageHeight: CGFloat = 30
}
